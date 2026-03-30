import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/rent_payment.dart';
import '../../core/utils/num_format.dart';
import '../../core/utils/date_utils.dart';
import 'pdf_service.dart';

class MonthlyRentsPdf {
  static Future<Uint8List> generate({
    required List<RentPayment> payments,
    required int month,
    required int year,
    required double totalExpenses,
    required double depositedAmount,
    required bool isArabic,
  }) async {
    await PdfFonts.load();

    final doc = pw.Document();
    final dir = PdfService.textDir(isArabic);
    final title = isArabic
        ? 'تقرير الإيجارات الشهرية'
        : 'Monthly Rents Report';
    final monthLabel =
        AppDateUtils.formatMonthYear(month, year, arabic: isArabic);

    final totalCollected =
        payments.fold<double>(0, (s, p) => s + p.amountPaid);
    final totalOutstanding =
        payments.fold<double>(0, (s, p) => s + p.outstandingAfter);
    final commission = totalCollected * 0.10;
    final netAmount = totalCollected - commission - totalExpenses;
    final leftAmount = netAmount - depositedAmount;

    // Column headers
    final headers = isArabic
        ? ['#', 'الشقة', 'المستأجر', 'الإيجار', 'المتأخر', 'المدفوع', 'الرصيد']
        : ['#', 'Apartment', 'Renter', 'Rent', 'Outstanding Before', 'Paid', 'Balance'];

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: dir,
        build: (ctx) => [
          // Header
          pw.Container(
            color: PdfService.primaryColor,
            padding: const pw.EdgeInsets.all(16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(title,
                    style: PdfService.headerStyle(isArabic),
                    textDirection: dir),
                pw.SizedBox(height: 4),
                pw.Text(monthLabel,
                    style: pw.TextStyle(
                        font: PdfFonts.regular,
                        color: const PdfColor(1, 1, 1, 0.7),
                        fontSize: 12),
                    textDirection: dir),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Table
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(0.5),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(1.5),
              4: const pw.FlexColumnWidth(1.5),
              5: const pw.FlexColumnWidth(1.5),
              6: const pw.FlexColumnWidth(1.5),
            },
            children: [
              // Header row
              pw.TableRow(
                decoration:
                    pw.BoxDecoration(color: PdfService.accentColor),
                children: headers
                    .map((h) => pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 4, vertical: 6),
                          child: pw.Text(h,
                              style: PdfService.boldStyle(isArabic),
                              textDirection: dir),
                        ))
                    .toList(),
              ),
              // Data rows
              ...payments.asMap().entries.map((entry) {
                final i = entry.key;
                final p = entry.value;
                final bg = i.isOdd ? PdfService.altRowColor : PdfColors.white;
                return pw.TableRow(
                  decoration: pw.BoxDecoration(color: bg),
                  children: [
                    _cell('${i + 1}', isArabic),
                    _cell(p.apartmentName ?? '', isArabic),
                    _cell(p.renterName ?? '', isArabic),
                    _cell(NumFormat.fmt(p.rentAmount), isArabic),
                    _cell(NumFormat.fmt(p.outstandingBefore), isArabic),
                    _cell(NumFormat.fmt(p.amountPaid), isArabic),
                    _cell(NumFormat.fmt(p.outstandingAfter), isArabic,
                        color: p.outstandingAfter > 0
                            ? PdfColors.orange800
                            : PdfColors.green800),
                  ],
                );
              }),
            ],
          ),

          pw.SizedBox(height: 20),

          // Summary
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfService.primaryColor, width: 1),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Column(
              children: [
                _summaryRow(
                    isArabic ? 'إجمالي المحصل' : 'Total Collected',
                    NumFormat.fmt(totalCollected),
                    isArabic),
                _summaryRow(
                    isArabic ? 'العمولة (10%)' : 'Commission (10%)',
                    NumFormat.fmt(commission),
                    isArabic),
                _summaryRow(
                    isArabic ? 'إجمالي المصاريف' : 'Total Expenses',
                    NumFormat.fmt(totalExpenses),
                    isArabic),
                _summaryRow(
                    isArabic ? 'الصافي' : 'Net Amount',
                    NumFormat.fmt(netAmount),
                    isArabic,
                    bold: true),
                _summaryRow(
                    isArabic ? 'المودع' : 'Deposited',
                    NumFormat.fmt(depositedAmount),
                    isArabic),
                _summaryRow(
                    isArabic ? 'المتبقي' : 'Left Amount',
                    NumFormat.fmt(leftAmount),
                    isArabic,
                    bold: true,
                    valueColor: leftAmount >= 0
                        ? PdfColors.green800
                        : PdfColors.red800),
                _summaryRow(
                    isArabic ? 'إجمالي المتأخرات' : 'Total Outstanding',
                    NumFormat.fmt(totalOutstanding),
                    isArabic,
                    valueColor: totalOutstanding > 0
                        ? PdfColors.orange800
                        : PdfColors.green800),
              ],
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _cell(String text, bool isArabic,
      {PdfColor? color}) =>
      pw.Padding(
        padding:
            const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            font: PdfFonts.regular,
            fontSize: 9,
            color: color,
          ),
          textDirection: PdfService.textDir(isArabic),
        ),
      );

  static pw.Widget _summaryRow(String label, String value, bool isArabic,
      {bool bold = false, PdfColor? valueColor}) {
    final dir = PdfService.textDir(isArabic);
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: PdfService.summaryLabelStyle(), textDirection: dir),
          pw.Text(value,
              style: pw.TextStyle(
                font: bold ? PdfFonts.bold : PdfFonts.regular,
                fontSize: bold ? 12 : 10,
                color: valueColor,
              ),
              textDirection: dir),
        ],
      ),
    );
  }
}
