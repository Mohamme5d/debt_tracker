import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raseed/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme.dart';
import '../../../core/db/models/debt_transaction.dart';
import '../../../core/db/models/enums.dart';
import '../../../core/db/models/person.dart';
import '../../../core/widgets/attachment_section.dart';
import '../../contacts/presentation/contact_picker_widget.dart';
import '../providers/transaction_provider.dart';

class EditTransactionScreen extends ConsumerStatefulWidget {
  const EditTransactionScreen({super.key, required this.transactionId});

  final int transactionId;

  @override
  ConsumerState<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState extends ConsumerState<EditTransactionScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _type = TransactionType.debt;
  Person? _selectedPerson;
  DateTime _date = DateTime.now();
  DateTime? _dueDate;
  List<String> _attachmentPaths = [];
  bool _isLoading = false;
  bool _isSaved = false;
  String? _personError;
  bool _initialized = false;
  DebtTransaction? _transaction;

  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  void _initFromTransaction(DebtTransaction tx) {
    if (_initialized) return;
    _initialized = true;
    _transaction = tx;
    _type = tx.type;
    _date = tx.date;
    _dueDate = tx.dueDate;
    _attachmentPaths = List<String>.from(tx.attachmentPaths);
    _amountController.text = tx.amount.toStringAsFixed(2);
    _noteController.text = tx.note ?? '';
    _selectedPerson = tx.person.value;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  Widget _stagger(int index, Widget child) {
    final start = (index * 0.1).clamp(0.0, 0.6);
    final end = (start + 0.5).clamp(start + 0.1, 1.0);
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _entranceController,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _entranceController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        )),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final txAsync = ref.watch(transactionByIdProvider(widget.transactionId));

    return txAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundDark,
          title: Text(l10n.editTransaction),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        appBar: AppBar(title: Text(l10n.editTransaction)),
        body: Center(
          child: Text('Error: $e', style: const TextStyle(color: Colors.white)),
        ),
      ),
      data: (tx) {
        if (tx == null) {
          return Scaffold(
            backgroundColor: AppTheme.backgroundDark,
            appBar: AppBar(title: Text(l10n.editTransaction)),
            body: const Center(
              child: Text('Transaction not found',
                  style: TextStyle(color: Colors.white)),
            ),
          );
        }
        _initFromTransaction(tx);

        final typeColor =
            _type == TransactionType.debt ? AppTheme.debtColor : AppTheme.loanColor;

        return Scaffold(
          backgroundColor: AppTheme.backgroundDark,
          appBar: AppBar(
            backgroundColor: AppTheme.backgroundDark,
            title: Text(l10n.editTransaction),
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => context.pop(),
            ),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Person
                _stagger(0, _buildLabel(l10n.person)),
                const SizedBox(height: 8),
                _stagger(0, _buildPersonSelector(l10n)),
                if (_personError != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: 4, start: 12),
                    child: Text(_personError!,
                        style: const TextStyle(
                            color: AppTheme.debtColor, fontSize: 12)),
                  ),
                const SizedBox(height: 24),

                // Type
                _stagger(1, _buildLabel(l10n.type)),
                const SizedBox(height: 8),
                _stagger(1, _buildTypeSelector(l10n, typeColor)),
                const SizedBox(height: 24),

                // Amount
                _stagger(2, _buildLabel(l10n.amount)),
                const SizedBox(height: 8),
                _stagger(
                  2,
                  TextFormField(
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: typeColor,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.attach_money, color: typeColor),
                      hintText: '0.00',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return l10n.amountRequired;
                      final a = double.tryParse(v);
                      if (a == null || a <= 0) return l10n.amountGreaterThanZero;
                      if (a < tx.amountPaid) {
                        return isAr
                            ? 'لا يمكن أن يكون أقل من المبلغ المدفوع (${tx.amountPaid.toStringAsFixed(2)})'
                            : 'Cannot be less than amount paid (${tx.amountPaid.toStringAsFixed(2)})';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Date
                _stagger(3, _buildLabel(l10n.date)),
                const SizedBox(height: 8),
                _stagger(
                  3,
                  _DateTile(
                    label: l10n.transactionDate,
                    date: _date,
                    onDateSelected: (d) => setState(() => _date = d),
                  ),
                ),
                const SizedBox(height: 24),

                // Due date
                _stagger(4, _buildLabel(l10n.dueDateOptional)),
                const SizedBox(height: 8),
                _stagger(
                  4,
                  _DateTile(
                    label: _dueDate == null ? l10n.setDueDate : l10n.dueDate,
                    date: _dueDate,
                    onDateSelected: (d) => setState(() => _dueDate = d),
                    onClear: _dueDate != null
                        ? () => setState(() => _dueDate = null)
                        : null,
                  ),
                ),
                const SizedBox(height: 24),

                // Note
                _stagger(5, _buildLabel(l10n.note)),
                const SizedBox(height: 8),
                _stagger(
                  5,
                  TextFormField(
                    controller: _noteController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(hintText: l10n.addNote),
                  ),
                ),
                const SizedBox(height: 24),

                // Attachments
                _stagger(
                  6,
                  AttachmentSection(
                    paths: _attachmentPaths,
                    onAdd: (p) => setState(() => _attachmentPaths.add(p)),
                    onRemove: (p) => setState(() => _attachmentPaths.remove(p)),
                  ),
                ),
                const SizedBox(height: 32),

                // Save button
                _stagger(7, _buildSaveButton(l10n, typeColor, tx)),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      );

  Widget _buildPersonSelector(AppLocalizations l10n) {
    return InkWell(
      onTap: _showContactPicker,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _selectedPerson != null
              ? AppTheme.primaryColor.withOpacity(0.08)
              : AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _personError != null
                ? AppTheme.debtColor
                : _selectedPerson != null
                    ? AppTheme.primaryColor.withOpacity(0.3)
                    : AppTheme.borderDark,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            if (_selectedPerson != null) ...[
              _avatar(_selectedPerson!.name),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _selectedPerson!.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16),
                ),
              ),
              Icon(Icons.swap_horiz, color: Colors.white.withOpacity(0.4)),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_add_outlined,
                    color: AppTheme.primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(l10n.selectPerson,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontSize: 16)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _avatar(String name) {
    final initials = name.isNotEmpty
        ? name
            .split(' ')
            .where((w) => w.isNotEmpty)
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join()
        : '?';
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AppTheme.avatarGradient(name)),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(initials,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16)),
      ),
    );
  }

  Widget _buildTypeSelector(AppLocalizations l10n, Color typeColor) {
    return Row(
      children: [
        Expanded(
          child: _TypeChip(
            label: l10n.debtIOwe,
            icon: Icons.arrow_upward_rounded,
            color: AppTheme.debtColor,
            isSelected: _type == TransactionType.debt,
            onTap: () => setState(() => _type = TransactionType.debt),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TypeChip(
            label: l10n.loanOwesMe,
            icon: Icons.arrow_downward_rounded,
            color: AppTheme.loanColor,
            isSelected: _type == TransactionType.loan,
            onTap: () => setState(() => _type = TransactionType.loan),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(AppLocalizations l10n, Color typeColor, DebtTransaction tx) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _isSaved
          ? Center(
              key: const ValueKey('saved'),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 400),
                curve: Curves.elasticOut,
                builder: (_, v, __) => Transform.scale(
                  scale: v,
                  child: const Icon(Icons.check_circle_rounded,
                      color: AppTheme.loanColor, size: 48),
                ),
              ),
            )
          : SizedBox(
              key: const ValueKey('btn'),
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : () => _save(tx),
                style: ElevatedButton.styleFrom(
                    backgroundColor: typeColor,
                    foregroundColor: Colors.white),
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_rounded),
                label: Text(l10n.save),
              ),
            ),
    );
  }

  void _showContactPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, __) => ContactPickerWidget(
          onPersonSelected: (p) => setState(() {
            _selectedPerson = p;
            _personError = null;
          }),
        ),
      ),
    );
  }

  Future<void> _save(DebtTransaction tx) async {
    if (_selectedPerson == null) {
      setState(() =>
          _personError = AppLocalizations.of(context)!.personRequired);
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final useCase = ref.read(editTransactionUseCaseProvider);
      final amount = double.parse(_amountController.text);
      final note = _noteController.text.isEmpty ? null : _noteController.text;

      await useCase.execute(
        transaction: tx,
        person: _selectedPerson!,
        type: _type,
        amount: amount,
        date: _date,
        dueDate: _dueDate,
        note: note,
        attachmentPaths: _attachmentPaths,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSaved = true;
        });
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isLoading = false);
      }
    }
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isSelected ? color : AppTheme.borderDark,
              width: isSelected ? 2 : 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isSelected ? color : Colors.white.withOpacity(0.4),
                size: 20),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.white.withOpacity(0.5),
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w400,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.date,
    required this.onDateSelected,
    this.onClear,
  });

  final String label;
  final DateTime? date;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final fmt = locale.languageCode == 'ar'
        ? DateFormat('yyyy/MM/dd', 'ar')
        : DateFormat('MMM dd, yyyy');

    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          locale: locale,
        );
        if (picked != null) onDateSelected(picked);
      },
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: date != null
              ? AppTheme.primaryColor.withOpacity(0.08)
              : AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: date != null
                ? AppTheme.primaryColor.withOpacity(0.3)
                : AppTheme.borderDark,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded,
                size: 20,
                color: date != null
                    ? AppTheme.primaryColor
                    : Colors.white.withOpacity(0.4)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                date != null ? fmt.format(date!) : label,
                style: TextStyle(
                  color: date != null
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                  fontWeight: date != null ? FontWeight.w500 : null,
                  fontSize: 15,
                ),
              ),
            ),
            if (onClear != null)
              IconButton(
                icon: Icon(Icons.clear_rounded,
                    size: 18, color: Colors.white.withOpacity(0.4)),
                onPressed: onClear,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }
}
