import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rent_manager/l10n/app_localizations.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import '../../core/utils/date_utils.dart';

class ExpenseFormScreen extends StatefulWidget {
  final String? expenseId;
  const ExpenseFormScreen({super.key, this.expenseId});

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _expenseDate = DateTime.now();
  bool _saving = false;
  Expense? _existing;

  @override
  void initState() {
    super.initState();
    if (widget.expenseId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = context.read<ExpenseProvider>();
        try {
          _existing = provider.expenses
              .firstWhere((e) => e.id == widget.expenseId);
          _descCtrl.text = _existing!.description;
          _amountCtrl.text = _existing!.amount.toString();
          _categoryCtrl.text = _existing!.category ?? '';
          _notesCtrl.text = _existing!.notes ?? '';
          _expenseDate = DateTime.parse(_existing!.expenseDate);
          setState(() {});
        } catch (_) {}
      });
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
    _categoryCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expenseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _expenseDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final provider = context.read<ExpenseProvider>();
    final expense = Expense(
      id: _existing?.id,
      description: _descCtrl.text.trim(),
      amount: double.parse(_amountCtrl.text.trim()),
      expenseDate: AppDateUtils.toIso(_expenseDate),
      category: _categoryCtrl.text.trim().isEmpty
          ? null
          : _categoryCtrl.text.trim(),
      month: _expenseDate.month,
      year: _expenseDate.year,
      notes:
          _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    final ok = _existing?.id == null
        ? await provider.add(expense)
        : await provider.edit(expense);
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
    final l = AppLocalizations.of(context)!;
    final isEdit = widget.expenseId != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? l.editExpense : l.addExpense)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _descCtrl,
              decoration: InputDecoration(labelText: l.description),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l.required : null,
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
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.expenseDate),
              subtitle: Text(AppDateUtils.toIso(_expenseDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _categoryCtrl,
              decoration: InputDecoration(labelText: l.category),
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
