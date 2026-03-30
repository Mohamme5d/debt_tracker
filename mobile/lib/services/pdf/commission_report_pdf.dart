import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../core/utils/num_format.dart';
import '../../core/utils/date_utils.dart';
import 'pdf_service.dart';

class CommissionReportPdf {
  static Future<Uint8List> generate({
    required List<Map<String, dynamic>> summaries,
    required bool isArabic,
  }) async {
    await PdfFonts.load();

    final doc = pw.Document();
    final dir = PdfService.textDir(isArabic);
    final title = isArabic ? 'تقرير العمولات' : 'Commission Report';

    final headers = isArabic
        ? ['#', 'الشهر', 'المحصل', 'العمولة 10%', 'التراكمي']
        : ['#', 'Month', 'Collected', 'Commission 10%', 'Cumulative'];

    double cumulative = 0.0;
    final rows = <List<String>>[];
    double grandTotalCommission = 0.0;

    for (int i = 0; i < summaries.length; i++) {
      final s = summaries[i];
      final month = s['payment_month'] as int;
      final year = s['payment_year'] as int;
      final collected = (s['total_collected'] as num?)?.toDouble() ?? 0.0;
      final commission = collected * 0.10;
      cumulative += commission;
      grandTotalCommission += commission;
      rows.add([
        '${i + 1}',
        AppDateUtils.formatMonthYear(month, year, arabic: isArabic),
        NumFormat.fmt(collected),
        NumFormat.fmt(commission),
        NumFormat.fmt(cumulative),
      ]);
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: dir,
        build: (ctx) => [
          // Header
          pw.Container(
            color: PdfService.primaryColor,
            padding: const pw.EdgeInsets.all(16),
            child: pw.Text(title,
                style: PdfService.headerStyle(isArabic), textDirection: dir),
          ),
          pw.SizedBox(height: 16),

          // Table
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(0.5),
              1: const pw.FlexColumnWidth(2.5),
              2: const pw.FlexColumnWidth(1.8),
              3: const pw.FlexColumnWidth(1.8),
              4: const pw.FlexColumnWidth(1.8),
            },
            children: [
              // Header row
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfService.accentColor),
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
              ...rows.asMap().entries.map((entry) {
                final i = entry.key;
                final r = entry.value;
                final bg =
                    i.isOdd ? PdfService.altRowColor : PdfColors.white;
                return pw.TableRow(
                  decoration: pw.BoxDecoration(color: bg),
                  children: r
                      .map((cell) => _cell(cell, isArabic))
                      .toList(),
                );
              }),
            ],
          ),

          pw.SizedBox(height: 20),

          // Summary
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border:
                  pw.Border.all(color: PdfService.primaryColor, width: 1),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  isArabic
                      ? 'إجمالي العمولات المتراكمة'
                      : 'Grand Total Commission',
                  style: PdfService.boldStyle(isArabic),
                  textDirection: dir,
                ),
                pw.Text(
                  NumFormat.fmt(grandTotalCommission),
                  style: pw.TextStyle(
                      font: PdfFonts.bold,
                      fontSize: 13,
                      color: PdfService.primaryColor),
                  textDirection: dir,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _cell(String text, bool isArabic) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: pw.Text(
          text,
          style: pw.TextStyle(font: PdfFonts.regular, fontSize: 9),
          textDirection: PdfService.textDir(isArabic),
        ),
      );
}
