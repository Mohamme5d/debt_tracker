import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rent_manager/l10n/app_localizations.dart';
import '../../models/monthly_deposit.dart';
import '../../providers/monthly_deposit_provider.dart';
import '../../widgets/common/month_year_picker.dart';

class DepositFormScreen extends StatefulWidget {
  final String? depositId;
  const DepositFormScreen({super.key, this.depositId});

  @override
  State<DepositFormScreen> createState() => _DepositFormScreenState();
}

class _DepositFormScreenState extends State<DepositFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  int _month = DateTime.now().month;
  int _year = DateTime.now().year;
  bool _saving = false;
  MonthlyDeposit? _existing;

  @override
  void initState() {
    super.initState();
    if (widget.depositId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = context.read<MonthlyDepositProvider>();
        try {
          _existing = provider.deposits
              .firstWhere((d) => d.id == widget.depositId);
          _month = _existing!.depositMonth;
          _year = _existing!.depositYear;
          _amountCtrl.text = _existing!.amount.toString();
          _notesCtrl.text = _existing!.notes ?? '';
          setState(() {});
        } catch (_) {}
      });
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final l = AppLocalizations.of(context)!;
    final provider = context.read<MonthlyDepositProvider>();
    final deposit = MonthlyDeposit(
      id: _existing?.id,
      depositMonth: _month,
      depositYear: _year,
      amount: double.parse(_amountCtrl.text.trim()),
      notes:
          _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    String result;
    if (_existing?.id == null) {
      result = await provider.add(deposit);
    } else {
      result = await provider.edit(deposit) ? 'ok' : 'error';
    }
    if (!mounted) return;
    setState(() => _saving = false);
    if (result == 'ok') {
      Navigator.of(context).pop();
    } else if (result == 'duplicate') {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.duplicatePayment)));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isEdit = widget.depositId != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? l.editDeposit : l.addDeposit)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            MonthYearPicker(
              initialMonth: _month,
              initialYear: _year,
              onChanged: (mv) =>
                  setState(() {
                    _month = mv.$1;
                    _year = mv.$2;
                  }),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountCtrl,
              decoration: InputDecoration(labelText: l.amount),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l.required;
                if (double.tryParse(v) == null) return l.invalidNumber;
                return null;
              },
            ),
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
