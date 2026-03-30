import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rent_manager/l10n/app_localizations.dart';
import '../../models/renter.dart';
import '../../providers/renter_provider.dart';

class RenterFormScreen extends StatefulWidget {
  final String? renterId;
  const RenterFormScreen({super.key, this.renterId});

  @override
  State<RenterFormScreen> createState() => _RenterFormScreenState();
}

class _RenterFormScreenState extends State<RenterFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _saving = false;
  Renter? _existing;

  @override
  void initState() {
    super.initState();
    if (widget.renterId != null) {
      final provider = context.read<RenterProvider>();
      _existing = provider.renters.firstWhere((r) => r.id == widget.renterId);
      _nameCtrl.text = _existing!.name;
      _phoneCtrl.text = _existing!.phone ?? '';
      _emailCtrl.text = _existing!.email ?? '';
      _notesCtrl.text = _existing!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final provider = context.read<RenterProvider>();
    final renter = Renter(
      id: _existing?.id,
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    final ok = _existing?.id == null
        ? await provider.add(renter)
        : await provider.edit(renter);
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
    final isEdit = widget.renterId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? l.editRenter : l.addRenter)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(labelText: l.name),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l.required : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneCtrl,
              decoration: InputDecoration(labelText: l.phone),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailCtrl,
              decoration: InputDecoration(labelText: l.email),
              keyboardType: TextInputType.emailAddress,
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
