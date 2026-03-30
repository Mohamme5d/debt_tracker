import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rent_manager/l10n/app_localizations.dart';
import '../../models/apartment.dart';
import '../../providers/apartment_provider.dart';

class ApartmentFormScreen extends StatefulWidget {
  final String? apartmentId;
  const ApartmentFormScreen({super.key, this.apartmentId});

  @override
  State<ApartmentFormScreen> createState() => _ApartmentFormScreenState();
}

class _ApartmentFormScreenState extends State<ApartmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _saving = false;

  Apartment? _existing;

  @override
  void initState() {
    super.initState();
    if (widget.apartmentId != null) {
      final provider = context.read<ApartmentProvider>();
      _existing = provider.apartments.firstWhere(
          (a) => a.id == widget.apartmentId,
          orElse: () => const Apartment(name: '', address: ''));
      _nameCtrl.text = _existing!.name;
      _addressCtrl.text = _existing!.address ?? '';
      _descCtrl.text = _existing!.description ?? '';
      _notesCtrl.text = _existing!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _descCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final provider = context.read<ApartmentProvider>();
    final apt = Apartment(
      id: _existing?.id,
      name: _nameCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    final ok = _existing?.id == null
        ? await provider.add(apt)
        : await provider.edit(apt);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isEdit = widget.apartmentId != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? l.editApartment : l.addApartment)),
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
              controller: _addressCtrl,
              decoration: InputDecoration(labelText: l.address),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l.required : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              decoration: InputDecoration(labelText: l.description),
              maxLines: 2,
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
