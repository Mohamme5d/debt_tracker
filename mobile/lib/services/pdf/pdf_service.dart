import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfFonts {
  static pw.Font? _regular;
  static pw.Font? _bold;

  static Future<void> load() async {
    final regData  = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
    final boldData = await rootBundle.load('assets/fonts/Cairo-Bold.ttf');
    _regular = pw.Font.ttf(regData);
    _bold    = pw.Font.ttf(boldData);
  }

  static pw.Font get regular => _regular!;
  static pw.Font get bold => _bold!;
}

class PdfService {
  static Future<void> share(Uint8List bytes, {String name = 'report.pdf'}) async {
    await Printing.sharePdf(bytes: bytes, filename: name);
  }

  static pw.TextStyle headerStyle(bool isArabic) => pw.TextStyle(
        font: PdfFonts.bold,
        fontSize: 18,
        color: PdfColors.white,
      );

  static pw.TextStyle bodyStyle(bool isArabic) => pw.TextStyle(
        font: PdfFonts.regular,
        fontSize: 10,
      );

  static pw.TextStyle boldStyle(bool isArabic) => pw.TextStyle(
        font: PdfFonts.bold,
        fontSize: 10,
      );

  static pw.TextStyle summaryLabelStyle() => pw.TextStyle(
        font: PdfFonts.regular,
        fontSize: 10,
        color: PdfColors.grey700,
      );

  static pw.TextStyle summaryValueStyle() => pw.TextStyle(
        font: PdfFonts.bold,
        fontSize: 11,
      );

  static pw.TextDirection textDir(bool isArabic) =>
      isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr;

  static PdfColor get primaryColor => PdfColor.fromHex('#1565C0');
  static PdfColor get accentColor => PdfColor.fromHex('#E3F2FD');
  static PdfColor get altRowColor => PdfColor.fromHex('#F5F5F5');
}
