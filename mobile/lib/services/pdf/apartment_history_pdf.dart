import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/rent_payment.dart';
import '../../core/utils/num_format.dart';
import '../../models/apartment.dart';
import '../../core/utils/date_utils.dart';
import 'pdf_service.dart';

class ApartmentHistoryPdf {
  static Future<Uint8List> generate({
    required Apartment apartment,
    required List<RentPayment> payments,
    required bool isArabic,
  }) async {
    await PdfFonts.load();

    final doc = pw.Document();
    final dir = PdfService.textDir(isArabic);
    final title =
        isArabic ? 'تقرير تاريخ الشقة' : 'Apartment History Report';
    final headers = isArabic
        ? ['الشهر', 'المستأجر', 'الإيجار', 'المدفوع']
        : ['Month', 'Renter', 'Rent', 'Paid'];

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: dir,
        build: (ctx) => [
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
                pw.Text(apartment.name,
                    style: pw.TextStyle(
                        font: PdfFonts.regular,
                        color: const PdfColor(1, 1, 1, 0.7),
                        fontSize: 12),
                    textDirection: dir),
                pw.Text(apartment.address ?? '',
                    style: pw.TextStyle(
                        font: PdfFonts.regular,
                        color: const PdfColor(1, 1, 1, 0.54),
                        fontSize: 10),
                    textDirection: dir),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(2.5),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1.5),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfService.accentColor),
                children: headers
                    .map((h) => _headerCell(h, isArabic))
                    .toList(),
              ),
              ...payments.asMap().entries.map((entry) {
                final i = entry.key;
                final p = entry.value;
                final bg = i.isOdd ? PdfService.altRowColor : PdfColors.white;
                return pw.TableRow(
                  decoration: pw.BoxDecoration(color: bg),
                  children: [
                    _cell(AppDateUtils.formatMonthYear(
                        p.paymentMonth, p.paymentYear,
                        arabic: isArabic), isArabic),
                    _cell(p.renterName ?? '', isArabic),
                    _cell(NumFormat.fmt(p.rentAmount), isArabic),
                    _cell(NumFormat.fmt(p.amountPaid), isArabic),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _headerCell(String text, bool isArabic) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: pw.Text(text,
            style: PdfService.boldStyle(isArabic),
            textDirection: PdfService.textDir(isArabic)),
      );

  static pw.Widget _cell(String text, bool isArabic, {PdfColor? color}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: pw.Text(text,
            style: pw.TextStyle(
                font: PdfFonts.regular, fontSize: 9, color: color),
            textDirection: PdfService.textDir(isArabic)),
      );
}
