import 'dart:typed_data';
import 'package:excel/excel.dart';
import '../../models/rent_payment.dart';

class MonthExcelData {
  final int month;
  final int year;
  final List<RentPayment> payments;
  final double totalExpenses;
  final double depositedAmount;

  const MonthExcelData({
    required this.month,
    required this.year,
    required this.payments,
    required this.totalExpenses,
    required this.depositedAmount,
  });
}

class RentExcelExport {
  // ---- Colors ----
  static final _headerBg = ExcelColor.fromHexString('1565C0');
  static final _headerFg = ExcelColor.fromHexString('FFFFFF');
  static final _subBg = ExcelColor.fromHexString('E3F2FD');
  static final _summaryBg = ExcelColor.fromHexString('F5F5F5');
  static final _altBg = ExcelColor.fromHexString('FAFAFA');
  static final _debtFg = ExcelColor.fromHexString('E65100');
  static final _okFg = ExcelColor.fromHexString('2E7D32');

  static Future<Uint8List> generate({
    required List<MonthExcelData> months,
    required bool isArabic,
  }) async {
    final excel = Excel.createExcel();
    // Remove default sheet
    excel.delete('Sheet1');

    // Build "All" sheet first (will be first tab)
    _buildAllSheet(excel, months, isArabic);

    // Build one sheet per month
    for (final m in months) {
      _buildMonthSheet(excel, m, isArabic);
    }

    return Uint8List.fromList(excel.save()!);
  }

  // ------------------------------------------------------------------
  // All-months sheet
  // ------------------------------------------------------------------
  static void _buildAllSheet(
      Excel excel, List<MonthExcelData> months, bool isArabic) {
    final sheetName = isArabic ? 'الكل' : 'All';
    final sheet = excel[sheetName];

    final headers = isArabic
        ? ['الشهر', 'الشقة', 'المستأجر', 'الإيجار', 'المتأخرات السابقة', 'المدفوع', 'المديونية المتبقية']
        : ['Month', 'Apartment', 'Renter', 'Rent', 'Outstanding Before', 'Paid', 'Balance'];

    _setColumnWidths(sheet, [18, 22, 22, 14, 18, 14, 18]);

    // Header row
    for (int c = 0; c < headers.length; c++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0));
      cell.value = TextCellValue(headers[c]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: _headerBg,
        fontColorHex: _headerFg,
        horizontalAlign: HorizontalAlign.Center,
      );
    }

    int row = 1;
    for (final m in months) {
      final monthLabel = '${m.month}-${m.year}';
      for (int i = 0; i < m.payments.length; i++) {
        final p = m.payments[i];
        final bg = i.isOdd ? _altBg : ExcelColor.fromHexString('FFFFFF');
        _setRow(sheet, row, [
          TextCellValue(monthLabel),
          TextCellValue(p.apartmentName ?? ''),
          TextCellValue(p.isVacant ? (isArabic ? 'شاغرة' : 'Vacant') : (p.renterName ?? '')),
          IntCellValue(p.rentAmount.toInt()),
          IntCellValue(p.outstandingBefore.toInt()),
          IntCellValue(p.amountPaid.toInt()),
          IntCellValue(p.outstandingAfter.toInt()),
        ], bg: bg, lastColColor: p.outstandingAfter > 0 ? _debtFg : _okFg);
        row++;
      }
    }
  }

  // ------------------------------------------------------------------
  // Per-month sheet
  // ------------------------------------------------------------------
  static void _buildMonthSheet(
      Excel excel, MonthExcelData m, bool isArabic) {
    final sheetName = '${m.month}-${m.year}';
    final sheet = excel[sheetName];

    final headers = isArabic
        ? ['الشقة', 'المستأجر', 'الإيجار الشهري', 'المتأخرات السابقة', 'المدفوع', 'المديونية المتبقية']
        : ['Apartment', 'Renter', 'Monthly Rent', 'Outstanding Before', 'Paid', 'Balance'];

    _setColumnWidths(sheet, [24, 24, 16, 18, 14, 18]);

    // Row 0: Title merged across A:F
    final title = isArabic
        ? 'إيجارات شهر $sheetName'
        : 'Rents for $sheetName';
    final titleCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
    titleCell.value = TextCellValue(title);
    titleCell.cellStyle = CellStyle(
      bold: true,
      backgroundColorHex: _headerBg,
      fontColorHex: _headerFg,
      horizontalAlign: HorizontalAlign.Center,
    );
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0),
    );

    // Row 1: Column headers
    for (int c = 0; c < headers.length; c++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 1));
      cell.value = TextCellValue(headers[c]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: _subBg,
        horizontalAlign: HorizontalAlign.Center,
      );
    }

    // Rows 2..N: payment data
    final activePayments = m.payments.where((p) => !p.isVacant).toList();
    double totalPaid = 0;

    for (int i = 0; i < m.payments.length; i++) {
      final p = m.payments[i];
      if (!p.isVacant) {
        totalPaid += p.amountPaid;
      }
      final bg = i.isOdd ? _altBg : ExcelColor.fromHexString('FFFFFF');
      _setRow(sheet, i + 2, [
        TextCellValue(p.apartmentName ?? ''),
        TextCellValue(p.isVacant ? (isArabic ? 'شاغرة' : 'Vacant') : (p.renterName ?? '')),
        p.isVacant ? TextCellValue('') : IntCellValue(p.rentAmount.toInt()),
        p.isVacant ? TextCellValue('') : IntCellValue(p.outstandingBefore.toInt()),
        p.isVacant ? TextCellValue('') : IntCellValue(p.amountPaid.toInt()),
        p.isVacant ? TextCellValue('') : IntCellValue(p.outstandingAfter.toInt()),
      ], bg: bg, lastColColor: (!p.isVacant && p.outstandingAfter > 0) ? _debtFg : null);
    }

    // Summary rows
    final commission = totalPaid * 0.10;
    final net = totalPaid - commission - m.totalExpenses;

    final int summaryStart = m.payments.length + 2;
    final summaryRows = isArabic
        ? [
            ['الاجمالي', totalPaid.toInt(), null],
            ['العمولة (10%)', commission.toInt(), null],
            ['المصروفات', m.totalExpenses.toInt(), null],
            ['الصافي المفروض ايداعه', net.toInt(), null],
            ['المبلغ المودع', m.depositedAmount.toInt(), null],
          ]
        : [
            ['Total Collected', totalPaid.toInt(), null],
            ['Commission (10%)', commission.toInt(), null],
            ['Expenses', m.totalExpenses.toInt(), null],
            ['Net to Deposit', net.toInt(), null],
            ['Deposited', m.depositedAmount.toInt(), null],
          ];

    for (int i = 0; i < summaryRows.length; i++) {
      final rowIdx = summaryStart + i;
      final label = summaryRows[i][0] as String;
      final value = summaryRows[i][1] as int;

      final labelCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIdx));
      labelCell.value = TextCellValue(label);
      labelCell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: _summaryBg,
      );
      // Merge label across cols 0-3
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIdx),
        CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIdx),
      );

      final valueCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIdx));
      valueCell.value = IntCellValue(value);
      final isNetRow = i == 3;
      valueCell.cellStyle = isNetRow
          ? CellStyle(
              bold: true,
              backgroundColorHex: _summaryBg,
              fontColorHex: net >= 0 ? _okFg : _debtFg,
            )
          : CellStyle(
              backgroundColorHex: _summaryBg,
            );
    }

    // Active renter count note
    final noteRow = summaryStart + summaryRows.length + 1;
    final noteCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: noteRow));
    noteCell.value = TextCellValue(
        isArabic ? 'عدد المستأجرين: ${activePayments.length}' : 'Active renters: ${activePayments.length}');
    noteCell.cellStyle = CellStyle(italic: true);
  }

  // ------------------------------------------------------------------
  // Helpers
  // ------------------------------------------------------------------
  static void _setColumnWidths(Sheet sheet, List<double> widths) {
    for (int i = 0; i < widths.length; i++) {
      sheet.setColumnWidth(i, widths[i]);
    }
  }

  static void _setRow(Sheet sheet, int row, List<CellValue> values,
      {required ExcelColor bg, ExcelColor? lastColColor}) {
    for (int c = 0; c < values.length; c++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: row));
      cell.value = values[c];
      final isLast = c == values.length - 1;
      if (isLast && lastColColor != null) {
        cell.cellStyle = CellStyle(
          backgroundColorHex: bg,
          fontColorHex: lastColColor,
        );
      } else {
        cell.cellStyle = CellStyle(backgroundColorHex: bg);
      }
    }
  }
}
