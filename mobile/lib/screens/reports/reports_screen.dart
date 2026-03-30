import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:rent_manager/l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../providers/apartment_provider.dart';
import '../../providers/renter_provider.dart';
import '../../providers/rent_payment_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/monthly_deposit_provider.dart';
import '../../models/apartment.dart';
import '../../models/renter.dart';
import '../../services/pdf/monthly_rents_pdf.dart';
import '../../services/pdf/renter_history_pdf.dart';
import '../../services/pdf/apartment_history_pdf.dart';
import '../../services/pdf/commission_report_pdf.dart';
import '../../services/excel/rent_excel_export.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../widgets/common/month_year_picker.dart';
import 'pdf_preview_screen.dart';

enum ReportType { monthlyRents, renterHistory, apartmentHistory, commissions, excel }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  ReportType _reportType = ReportType.monthlyRents;
  int _month = DateTime.now().month;
  int _year = DateTime.now().year;
  Renter? _selectedRenter;
  Apartment? _selectedApartment;
  bool _generating = false;
  // Excel export
  List<int> _availableYears = [];
  int? _excelYear; // null = all time

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApartmentProvider>().load();
      context.read<RenterProvider>().load();
      _loadYears();
    });
  }

  Future<void> _loadYears() async {
    final years = await context.read<RentPaymentProvider>().getDistinctYears();
    if (mounted) setState(() => _availableYears = years);
  }

  Future<void> _generate() async {
    setState(() => _generating = true);
    final l = AppLocalizations.of(context)!;
    final isArabic = context.read<LocaleProvider>().isArabic;
    final paymentProvider = context.read<RentPaymentProvider>();
    final expenseProvider = context.read<ExpenseProvider>();
    final depositProvider = context.read<MonthlyDepositProvider>();

    try {
      switch (_reportType) {
        case ReportType.monthlyRents:
          final payments =
              await paymentProvider.getByMonthYear(_month, _year);
          final totalExpenses =
              await expenseProvider.getTotalByMonthYear(_month, _year);
          final deposit =
              await depositProvider.getByMonthYear(_month, _year);
          final bytes = await MonthlyRentsPdf.generate(
            payments: payments,
            month: _month,
            year: _year,
            totalExpenses: totalExpenses,
            depositedAmount: deposit?.amount ?? 0.0,
            isArabic: isArabic,
          );
          if (mounted) {
            Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
              builder: (_) => PdfPreviewScreen(
                bytes: bytes,
                filename: 'monthly_rents_${_month}_$_year.pdf',
              ),
            ));
          }

        case ReportType.renterHistory:
          if (_selectedRenter == null) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l.selectRenter)));
            setState(() => _generating = false);
            return;
          }
          final payments =
              await paymentProvider.getByRenter(_selectedRenter!.id!);
          final bytes = await RenterHistoryPdf.generate(
            renter: _selectedRenter!,
            payments: payments,
            isArabic: isArabic,
          );
          if (mounted) {
            Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
              builder: (_) => PdfPreviewScreen(
                bytes: bytes,
                filename: 'renter_${_selectedRenter!.name.replaceAll(' ', '_')}.pdf',
              ),
            ));
          }

        case ReportType.apartmentHistory:
          if (_selectedApartment == null) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l.selectApartment)));
            setState(() => _generating = false);
            return;
          }
          final payments = await paymentProvider
              .getByApartment(_selectedApartment!.id!);
          final bytes = await ApartmentHistoryPdf.generate(
            apartment: _selectedApartment!,
            payments: payments,
            isArabic: isArabic,
          );
          if (mounted) {
            Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
              builder: (_) => PdfPreviewScreen(
                bytes: bytes,
                filename: 'apartment_${_selectedApartment!.name.replaceAll(' ', '_')}.pdf',
              ),
            ));
          }

        case ReportType.commissions:
          final summaries = await paymentProvider.getAllMonthlySummaries();
          final bytes = await CommissionReportPdf.generate(
            summaries: summaries,
            isArabic: isArabic,
          );
          if (mounted) {
            Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
              builder: (_) => PdfPreviewScreen(
                bytes: bytes,
                filename: 'commission_report.pdf',
              ),
            ));
          }

        case ReportType.excel:
          final allSummaries = await paymentProvider.getAllMonthlySummaries();
          final months = _excelYear == null
              ? allSummaries
              : allSummaries.where((s) => s['payment_year'] == _excelYear).toList();

          final monthDataList = <MonthExcelData>[];
          for (final s in months) {
            final mo = s['payment_month'] as int;
            final yr = s['payment_year'] as int;
            final payments = await paymentProvider.getByMonthYear(mo, yr);
            final expenses = await expenseProvider.getTotalByMonthYear(mo, yr);
            final deposit = await depositProvider.getByMonthYear(mo, yr);
            monthDataList.add(MonthExcelData(
              month: mo,
              year: yr,
              payments: payments,
              totalExpenses: expenses,
              depositedAmount: deposit?.amount ?? 0.0,
            ));
          }

          final xlBytes = await RentExcelExport.generate(
            months: monthDataList,
            isArabic: isArabic,
          );

          final dir = await getTemporaryDirectory();
          final yearStr = _excelYear?.toString() ?? 'all';
          final file = File('${dir.path}/rents_$yearStr.xlsx');
          await file.writeAsBytes(xlBytes);
          if (mounted) {
            await Share.shareXFiles(
              [XFile(file.path)],
              subject: isArabic ? 'تقرير الإيجارات' : 'Rent Report',
            );
          }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final apartments = context.watch<ApartmentProvider>().apartments;
    final renters = context.watch<RenterProvider>().renters;

    return Scaffold(
      appBar: AppBar(title: Text(l.reports)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Report type selector
          Card(
            child: Column(
              children: [
                RadioListTile<ReportType>(
                  title: Text(l.monthlyRentsReport),
                  value: ReportType.monthlyRents,
                  groupValue: _reportType,
                  onChanged: (v) => setState(() => _reportType = v!),
                ),
                RadioListTile<ReportType>(
                  title: Text(l.renterHistoryReport),
                  value: ReportType.renterHistory,
                  groupValue: _reportType,
                  onChanged: (v) => setState(() => _reportType = v!),
                ),
                RadioListTile<ReportType>(
                  title: Text(l.apartmentHistoryReport),
                  value: ReportType.apartmentHistory,
                  groupValue: _reportType,
                  onChanged: (v) => setState(() => _reportType = v!),
                ),
                RadioListTile<ReportType>(
                  title: Text(l.commissionReport),
                  value: ReportType.commissions,
                  groupValue: _reportType,
                  onChanged: (v) => setState(() => _reportType = v!),
                ),
                RadioListTile<ReportType>(
                  title: Text(l.excelExport),
                  value: ReportType.excel,
                  groupValue: _reportType,
                  onChanged: (v) => setState(() => _reportType = v!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Filters based on report type
          if (_reportType == ReportType.monthlyRents) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: MonthYearPicker(
                  initialMonth: _month,
                  initialYear: _year,
                  onChanged: (mv) =>
                      setState(() {
                        _month = mv.$1;
                        _year = mv.$2;
                      }),
                ),
              ),
            ),
          ],

          if (_reportType == ReportType.renterHistory) ...[
            DropdownSearch<Renter>(
              key: ValueKey('renter_${renters.length}'),
              items: renters,
              filterFn: (item, filter) =>
                  item.name.toLowerCase().contains(filter.toLowerCase()),
              selectedItem: _selectedRenter,
              itemAsString: (r) => r.name,
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(labelText: l.renter),
              ),
              popupProps: PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(hintText: l.searchRenter),
                ),
              ),
              onChanged: (r) => setState(() => _selectedRenter = r),
            ),
          ],

          if (_reportType == ReportType.excel) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: DropdownButtonFormField<int?>(
                  value: _excelYear,
                  decoration: InputDecoration(
                    labelText: l.selectYear,
                    border: InputBorder.none,
                  ),
                  items: [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text(l.allTime),
                    ),
                    ..._availableYears.map((y) => DropdownMenuItem<int?>(
                          value: y,
                          child: Text('$y'),
                        )),
                  ],
                  onChanged: (v) => setState(() => _excelYear = v),
                ),
              ),
            ),
          ],

          if (_reportType == ReportType.apartmentHistory) ...[
            DropdownSearch<Apartment>(
              key: ValueKey('apt_${apartments.length}'),
              items: apartments,
              filterFn: (item, filter) =>
                  item.name.toLowerCase().contains(filter.toLowerCase()),
              selectedItem: _selectedApartment,
              itemAsString: (a) => a.name,
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(labelText: l.apartment),
              ),
              popupProps: PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(hintText: l.searchApartment),
                ),
              ),
              onChanged: (a) => setState(() => _selectedApartment = a),
            ),
          ],

          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _generating ? null : _generate,
            icon: _generating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.picture_as_pdf),
            label: Text(l.generateReport),
          ),
        ],
      ),
    );
  }
}
