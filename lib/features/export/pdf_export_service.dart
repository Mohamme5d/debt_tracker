import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/db/models/debt_transaction.dart';
import '../../core/db/models/enums.dart';
import '../../core/db/models/person.dart';
import '../../l10n/app_localizations.dart';

class PdfExportService {
  static final _formatter = NumberFormat('#,##0.00');

  Future<Uint8List> generateTransactionReport({
    required List<DebtTransaction> transactions,
    Person? person,
    DateTimeRange? dateRange,
    required AppLocalizations l10n,
    required bool isArabic,
  }) async {
    final font = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();

    final pdf = pw.Document();

    final baseStyle = pw.TextStyle(font: font, fontSize: 10);
    final boldStyle = pw.TextStyle(font: fontBold, fontSize: 10);
    final headerStyle = pw.TextStyle(font: fontBold, fontSize: 20);
    final subHeaderStyle = pw.TextStyle(font: fontBold, fontSize: 14);

    final textDirection =
        isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr;

    double totalDebt = 0;
    double totalLoan = 0;
    double totalPaid = 0;

    for (final tx in transactions) {
      await tx.person.load();
      if (tx.type == TransactionType.debt) {
        totalDebt += tx.amount;
      } else {
        totalLoan += tx.amount;
      }
      totalPaid += tx.amountPaid;
    }

    final dateFormat = DateFormat('yyyy/MM/dd');
    final reportDate = dateFormat.format(DateTime.now());

    // Summary page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: textDirection,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(l10n.reportTitle,
                    style: headerStyle, textDirection: textDirection),
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  '${l10n.date}: $reportDate',
                  style: baseStyle,
                  textDirection: textDirection,
                ),
              ),
              if (person != null) ...[
                pw.SizedBox(height: 4),
                pw.Center(
                  child: pw.Text(
                    l10n.transactionsFor(person.name),
                    style: baseStyle,
                    textDirection: textDirection,
                  ),
                ),
              ],
              if (dateRange != null) ...[
                pw.SizedBox(height: 4),
                pw.Center(
                  child: pw.Text(
                    '${dateFormat.format(dateRange.start)} - ${dateFormat.format(dateRange.end)}',
                    style: baseStyle,
                    textDirection: textDirection,
                  ),
                ),
              ],
              pw.SizedBox(height: 24),
              pw.Divider(),
              pw.SizedBox(height: 16),
              pw.Text(l10n.summary,
                  style: subHeaderStyle, textDirection: textDirection),
              pw.SizedBox(height: 12),
              _buildSummaryRow(
                  l10n.iOwe, _formatter.format(totalDebt), font, fontBold,
                  textDirection: textDirection),
              pw.SizedBox(height: 6),
              _buildSummaryRow(
                  l10n.owedToMe, _formatter.format(totalLoan), font, fontBold,
                  textDirection: textDirection),
              pw.SizedBox(height: 6),
              _buildSummaryRow(
                  l10n.paid, _formatter.format(totalPaid), font, fontBold,
                  textDirection: textDirection),
              pw.SizedBox(height: 6),
              pw.Divider(),
              _buildSummaryRow(l10n.netBalance,
                  _formatter.format(totalLoan - totalDebt), font, fontBold,
                  textDirection: textDirection),
              pw.SizedBox(height: 24),
              pw.Text(
                '${l10n.total}: ${transactions.length} ${l10n.transactions}',
                style: baseStyle,
                textDirection: textDirection,
              ),
            ],
          );
        },
      ),
    );

    // Transaction table pages
    if (transactions.isNotEmpty) {
      final headers = [
        l10n.person,
        l10n.type,
        l10n.amount,
        l10n.paid,
        l10n.remaining,
        l10n.date,
        l10n.status,
      ];

      final rows = transactions.map((tx) {
        final personName = tx.person.value?.name ?? '-';
        final typeName =
            tx.type == TransactionType.debt ? l10n.debt : l10n.loan;
        final statusName = tx.status == TransactionStatus.settled
            ? l10n.settled
            : tx.status == TransactionStatus.overdue
                ? l10n.overdue
                : l10n.active;

        return [
          personName,
          typeName,
          _formatter.format(tx.amount),
          _formatter.format(tx.amountPaid),
          _formatter.format(tx.remaining),
          dateFormat.format(tx.date),
          statusName,
        ];
      }).toList();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          textDirection: textDirection,
          build: (context) => [
            pw.Text(l10n.allTransactions,
                style: subHeaderStyle, textDirection: textDirection),
            pw.SizedBox(height: 12),
            pw.TableHelper.fromTextArray(
              context: context,
              headers: headers,
              data: rows,
              headerStyle: boldStyle,
              cellStyle: baseStyle,
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              cellAlignments: {
                0: pw.Alignment.centerRight,
                1: pw.Alignment.center,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
                5: pw.Alignment.center,
                6: pw.Alignment.center,
              },
              rowDecoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(
                    color: PdfColors.grey200,
                    width: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return pdf.save();
  }

  pw.Widget _buildSummaryRow(
    String label,
    String value,
    pw.Font font,
    pw.Font fontBold, {
    required pw.TextDirection textDirection,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label,
            style: pw.TextStyle(font: font, fontSize: 12),
            textDirection: textDirection),
        pw.Text(value,
            style: pw.TextStyle(font: fontBold, fontSize: 12),
            textDirection: textDirection),
      ],
    );
  }

  Future<void> sharePdf(Uint8List bytes, String filename) async {
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }
}
