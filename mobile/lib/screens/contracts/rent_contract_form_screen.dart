import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../models/rent_contract.dart';
import '../../models/renter.dart';
import '../../models/apartment.dart';
import '../../providers/rent_contract_provider.dart';
import '../../providers/renter_provider.dart';
import '../../providers/apartment_provider.dart';
import '../../core/utils/date_utils.dart';

class RentContractFormScreen extends StatefulWidget {
  final String? contractId;
  const RentContractFormScreen({super.key, this.contractId});

  @override
  State<RentContractFormScreen> createState() => _RentContractFormScreenState();
}

class _RentContractFormScreenState extends State<RentContractFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rentCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  Renter? _selectedRenter;
  Apartment? _selectedApartment;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isActive = true;
  bool _saving = false;
  RentContract? _existing;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RenterProvider>().load();
      context.read<ApartmentProvider>().load();
      if (widget.contractId != null) _loadExisting();
    });
  }

  void _loadExisting() {
    final provider = context.read<RentContractProvider>();
    try {
      _existing = provider.contracts.firstWhere((c) => c.id == widget.contractId);
      _rentCtrl.text = _existing!.monthlyRent.toString();
      _notesCtrl.text = _existing!.notes ?? '';
      _isActive = _existing!.isActive;
      _startDate = DateTime.parse(_existing!.startDate);
      if (_existing!.endDate != null) {
        _endDate = DateTime.parse(_existing!.endDate!);
      }
      setState(() {});
    } catch (_) {}
  }

  @override
  void dispose() {
    _rentCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final initial = isStart ? _startDate : (_endDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRenter == null && _existing?.renterId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى اختيار المستأجر / Select renter')));
      return;
    }
    if (_selectedApartment == null && _existing?.apartmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى اختيار الشقة / Select apartment')));
      return;
    }
    setState(() => _saving = true);
    final provider = context.read<RentContractProvider>();
    final contract = RentContract(
      id: _existing?.id,
      renterId: _selectedRenter?.id ?? _existing!.renterId,
      renterName: _selectedRenter?.name ?? _existing!.renterName,
      apartmentId: _selectedApartment?.id ?? _existing!.apartmentId,
      apartmentName: _selectedApartment?.name ?? _existing!.apartmentName,
      monthlyRent: double.parse(_rentCtrl.text.trim()),
      startDate: AppDateUtils.toIso(_startDate),
      endDate: _endDate != null ? AppDateUtils.toIso(_endDate!) : null,
      isActive: _isActive,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    final ok = _existing?.id == null
        ? await provider.add(contract)
        : await provider.edit(contract);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(provider.error ?? 'Error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final renters = context.watch<RenterProvider>().renters;
    final apartments = context.watch<ApartmentProvider>().apartments;
    final isEdit = widget.contractId != null;

    // Pre-select existing items
    if (_selectedRenter == null && _existing != null && renters.isNotEmpty) {
      try {
        _selectedRenter = renters.firstWhere((r) => r.id == _existing!.renterId);
      } catch (_) {}
    }
    if (_selectedApartment == null && _existing != null && apartments.isNotEmpty) {
      try {
        _selectedApartment = apartments.firstWhere((a) => a.id == _existing!.apartmentId);
      } catch (_) {}
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'تعديل عقد / Edit Contract' : 'إضافة عقد / Add Contract'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownSearch<Renter>(
              items: renters,
              filterFn: (item, filter) =>
                  item.name.toLowerCase().contains(filter.toLowerCase()),
              selectedItem: _selectedRenter,
              itemAsString: (r) => r.name,
              dropdownDecoratorProps: const DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(labelText: 'المستأجر / Renter *'),
              ),
              popupProps: const PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(hintText: 'بحث...'),
                ),
              ),
              onChanged: (r) => setState(() => _selectedRenter = r),
              validator: (v) => v == null ? 'مطلوب / Required' : null,
            ),
            const SizedBox(height: 12),
            DropdownSearch<Apartment>(
              items: apartments,
              filterFn: (item, filter) =>
                  item.name.toLowerCase().contains(filter.toLowerCase()),
              selectedItem: _selectedApartment,
              itemAsString: (a) => a.name,
              dropdownDecoratorProps: const DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(labelText: 'الشقة / Apartment *'),
              ),
              popupProps: const PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(hintText: 'بحث...'),
                ),
              ),
              onChanged: (a) => setState(() => _selectedApartment = a),
              validator: (v) => v == null ? 'مطلوب / Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _rentCtrl,
              decoration: const InputDecoration(labelText: 'الإيجار الشهري / Monthly Rent *'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'مطلوب / Required';
                if (double.tryParse(v) == null) return 'رقم غير صحيح';
                return null;
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('تاريخ البداية / Start Date'),
              subtitle: Text(_startDate.toIso8601String().split('T').first),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(true),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('تاريخ الانتهاء / End Date (اختياري)'),
              subtitle: Text(_endDate?.toIso8601String().split('T').first ?? '—'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(false),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('نشط / Active'),
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: 'ملاحظات / Notes'),
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
                  : const Text('حفظ / Save'),
            ),
          ],
        ),
      ),
    );
  }
}
