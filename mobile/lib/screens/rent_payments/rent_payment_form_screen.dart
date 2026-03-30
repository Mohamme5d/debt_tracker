import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:rent_manager/l10n/app_localizations.dart';
import '../../models/rent_payment.dart';
import '../../models/rent_contract.dart';
import '../../models/apartment.dart';
import '../../providers/rent_payment_provider.dart';
import '../../providers/rent_contract_provider.dart';
import '../../providers/apartment_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/month_year_picker.dart';
import '../../core/utils/num_format.dart';

class RentPaymentFormScreen extends StatefulWidget {
  final String? paymentId;
  const RentPaymentFormScreen({super.key, this.paymentId});

  @override
  State<RentPaymentFormScreen> createState() => _RentPaymentFormScreenState();
}

class _RentPaymentFormScreenState extends State<RentPaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rentAmountCtrl = TextEditingController();
  final _amountPaidCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  RentContract? _selectedContract;
  Apartment? _selectedApartment;
  bool _isVacant = false;
  int _month = DateTime.now().month;
  int _year = DateTime.now().year;
  double _outstandingBefore = 0.0;
  double _outstandingAfter = 0.0;
  bool _saving = false;
  bool _loadingOutstanding = false;
  RentPayment? _existing;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RentContractProvider>().load();
      context.read<ApartmentProvider>().load();
      if (widget.paymentId != null) _loadExisting();
    });
    _amountPaidCtrl.addListener(_recalcOutstandingAfter);
    _rentAmountCtrl.addListener(_recalcOutstandingAfter);
  }

  Future<void> _loadExisting() async {
    final provider = context.read<RentPaymentProvider>();
    final p = provider.payments.firstWhere((p) => p.id == widget.paymentId);
    _existing = p;
    _month = p.paymentMonth;
    _year = p.paymentYear;
    _isVacant = p.isVacant;
    _outstandingBefore = p.outstandingBefore;
    _outstandingAfter = p.outstandingAfter;
    _rentAmountCtrl.text = p.rentAmount.toString();
    _amountPaidCtrl.text = p.amountPaid.toString();
    _notesCtrl.text = p.notes ?? '';
    if (p.isVacant) {
      final apts = context.read<ApartmentProvider>().apartments;
      try {
        _selectedApartment = apts.firstWhere((a) => a.id == p.apartmentId);
      } catch (_) {}
    } else if (p.contractId != null) {
      final contracts = context.read<RentContractProvider>().contracts;
      try {
        _selectedContract = contracts.firstWhere((c) => c.id == p.contractId);
      } catch (_) {}
    }
    setState(() {});
  }

  @override
  void dispose() {
    _rentAmountCtrl.dispose();
    _amountPaidCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _recalcOutstandingAfter() {
    final rent = double.tryParse(_rentAmountCtrl.text) ?? 0.0;
    final paid = double.tryParse(_amountPaidCtrl.text) ?? 0.0;
    setState(() => _outstandingAfter = _outstandingBefore + rent - paid);
  }

  Future<void> _onContractSelected(RentContract? contract) async {
    if (contract == null) return;
    setState(() {
      _selectedContract = contract;
      _rentAmountCtrl.text = contract.monthlyRent.toString();
      _loadingOutstanding = true;
    });
    final ob = await context
        .read<RentPaymentProvider>()
        .getPreviousOutstandingByApartment(contract.apartmentId, _month, _year);
    if (!mounted) return;
    setState(() {
      _outstandingBefore = ob;
      _loadingOutstanding = false;
    });
    _recalcOutstandingAfter();
  }

  Future<void> _onApartmentSelected(Apartment? apt) async {
    if (apt == null) return;
    setState(() {
      _selectedApartment = apt;
      _loadingOutstanding = true;
      _rentAmountCtrl.text = '0';
      _amountPaidCtrl.text = '0';
    });
    final ob = await context
        .read<RentPaymentProvider>()
        .getPreviousOutstandingByApartment(apt.id!, _month, _year);
    if (!mounted) return;
    setState(() {
      _outstandingBefore = ob;
      _loadingOutstanding = false;
    });
    _recalcOutstandingAfter();
  }

  Future<void> _onMonthYearChanged(int month, int year) async {
    setState(() {
      _month = month;
      _year = year;
    });
    final aptId = _isVacant
        ? _selectedApartment?.id
        : _selectedContract?.apartmentId;
    if (aptId != null) {
      setState(() => _loadingOutstanding = true);
      final ob = await context
          .read<RentPaymentProvider>()
          .getPreviousOutstandingByApartment(aptId, month, year);
      if (!mounted) return;
      setState(() {
        _outstandingBefore = ob;
        _loadingOutstanding = false;
      });
      _recalcOutstandingAfter();
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isVacant && _selectedApartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.selectApartment)));
      return;
    }
    if (!_isVacant && _selectedContract == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى اختيار العقد / Select contract')));
      return;
    }
    setState(() => _saving = true);
    final l = AppLocalizations.of(context)!;
    final provider = context.read<RentPaymentProvider>();

    final payment = _isVacant
        ? RentPayment(
            id: _existing?.id,
            contractId: null,
            renterId: null,
            apartmentId: _selectedApartment!.id!,
            paymentMonth: _month,
            paymentYear: _year,
            rentAmount: 0,
            outstandingBefore: _outstandingBefore,
            amountPaid: 0,
            outstandingAfter: _outstandingBefore,
            isVacant: true,
            notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          )
        : RentPayment(
            id: _existing?.id,
            contractId: _selectedContract!.id,
            renterId: _selectedContract!.renterId,
            apartmentId: _selectedContract!.apartmentId,
            paymentMonth: _month,
            paymentYear: _year,
            rentAmount: double.parse(_rentAmountCtrl.text),
            outstandingBefore: _outstandingBefore,
            amountPaid: double.tryParse(_amountPaidCtrl.text) ?? 0.0,
            outstandingAfter: _outstandingAfter,
            isVacant: false,
            notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          );

    final String result;
    if (_existing?.id == null) {
      result = await provider.add(payment);
    } else {
      result = await provider.edit(payment) ? 'ok' : 'error';
    }

    if (!mounted) return;
    setState(() => _saving = false);
    if (result == 'ok') {
      Navigator.of(context).pop();
    } else if (result == 'duplicate') {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.duplicatePayment)));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final contracts = context.watch<RentContractProvider>().activeContracts;
    final apartments = context.watch<ApartmentProvider>().apartments;
    final isEdit = widget.paymentId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? l.editPayment : l.addPayment)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Vacant toggle ─────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: _isVacant
                    ? AppColors.warning.withValues(alpha: 0.1)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isVacant
                      ? AppColors.warning.withValues(alpha: 0.4)
                      : AppColors.border,
                ),
              ),
              child: SwitchListTile(
                value: _isVacant,
                onChanged: (v) => setState(() {
                  _isVacant = v;
                  _selectedContract = null;
                  _selectedApartment = null;
                  _outstandingBefore = 0;
                  _outstandingAfter = 0;
                  _rentAmountCtrl.text = '';
                  _amountPaidCtrl.text = '';
                }),
                title: Text(
                  'شاغرة / Vacant',
                  style: TextStyle(
                    color: _isVacant ? AppColors.warning : Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  _isVacant
                      ? 'الشقة شاغرة هذا الشهر'
                      : 'Apartment is occupied this month',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
                activeColor: AppColors.warning,
              ),
            ),
            const SizedBox(height: 12),

            // ── Contract or Apartment selector ────────────────────────────
            if (_isVacant)
              DropdownSearch<Apartment>(
                items: apartments,
                filterFn: (item, filter) =>
                    item.name.toLowerCase().contains(filter.toLowerCase()),
                selectedItem: _selectedApartment,
                itemAsString: (a) => a.name,
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration:
                      InputDecoration(labelText: l.apartment),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(hintText: l.searchApartment),
                  ),
                ),
                onChanged: _onApartmentSelected,
              )
            else
              DropdownSearch<RentContract>(
                items: contracts,
                filterFn: (item, filter) =>
                    item.renterName.toLowerCase().contains(filter.toLowerCase()) ||
                    item.apartmentName.toLowerCase().contains(filter.toLowerCase()),
                selectedItem: _selectedContract,
                itemAsString: (c) => '${c.renterName} — ${c.apartmentName}',
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: 'العقد / Contract',
                  ),
                ),
                popupProps: const PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(hintText: 'بحث عن عقد...'),
                  ),
                ),
                onChanged: _onContractSelected,
              ),
            const SizedBox(height: 12),

            MonthYearPicker(
              initialMonth: _month,
              initialYear: _year,
              onChanged: (mv) => _onMonthYearChanged(mv.$1, mv.$2),
            ),

            if (!_isVacant) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _rentAmountCtrl,
                decoration: InputDecoration(labelText: l.rentAmount),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l.required;
                  if (double.tryParse(v) == null) return l.invalidNumber;
                  return null;
                },
              ),
              const SizedBox(height: 12),
              if (_loadingOutstanding)
                const Center(child: CircularProgressIndicator())
              else
                InputDecorator(
                  decoration: InputDecoration(labelText: l.outstandingBefore),
                  child: Text(NumFormat.fmt(_outstandingBefore)),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountPaidCtrl,
                decoration: InputDecoration(labelText: l.amountPaid),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l.required;
                  if (double.tryParse(v) == null) return l.invalidNumber;
                  return null;
                },
              ),
              const SizedBox(height: 12),
              InputDecorator(
                decoration: InputDecoration(
                  labelText: l.outstandingAfter,
                  labelStyle: TextStyle(
                    color: _outstandingAfter > 0 ? Colors.orange : Colors.green,
                  ),
                ),
                child: Text(
                  NumFormat.fmt(_outstandingAfter),
                  style: TextStyle(
                    color: _outstandingAfter > 0 ? Colors.orange : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ] else if (_loadingOutstanding) ...[
              const SizedBox(height: 12),
              const Center(child: CircularProgressIndicator()),
            ] else if (_outstandingBefore != 0) ...[
              const SizedBox(height: 12),
              InputDecorator(
                decoration: InputDecoration(labelText: l.outstandingBefore),
                child: Text(
                  NumFormat.fmt(_outstandingBefore),
                  style: const TextStyle(color: AppColors.warning),
                ),
              ),
            ],

            const SizedBox(height: 12),
            TextFormField(
              controller: _notesCtrl,
              decoration: InputDecoration(labelText: l.notes),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l.save),
            ),
          ],
        ),
      ),
    );
  }
}
