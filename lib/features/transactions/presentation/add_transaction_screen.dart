import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme.dart';
import '../../../core/db/models/enums.dart';
import '../../../core/db/models/person.dart';
import '../../contacts/presentation/contact_picker_widget.dart';
import '../providers/transaction_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key, this.personId});

  final int? personId;

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _type = TransactionType.debt;
  Person? _selectedPerson;
  DateTime _date = DateTime.now();
  DateTime? _dueDate;
  bool _isLoading = false;
  bool _isSaved = false;
  String? _personError;

  late final AnimationController _entranceController;
  late final AnimationController _typeColorController;
  late final AnimationController _saveAnimController;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _typeColorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _saveAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    if (widget.personId != null) {
      _loadPerson();
    }
  }

  Future<void> _loadPerson() async {
    final person = await ref.read(
      personByIdProvider(widget.personId!).future,
    );
    if (mounted && person != null) {
      setState(() => _selectedPerson = person);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _entranceController.dispose();
    _typeColorController.dispose();
    _saveAnimController.dispose();
    super.dispose();
  }

  Widget _buildStaggeredChild(int index, Widget child) {
    final start = (index * 0.08).clamp(0.0, 0.6);
    final end = (start + 0.5).clamp(start + 0.1, 1.0);

    final slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    ));

    final fadeAnim = CurvedAnimation(
      parent: _entranceController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: slideAnim,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final typeColor =
        _type == TransactionType.debt ? AppTheme.debtColor : AppTheme.loanColor;

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        title: Text(l10n.addTransaction),
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
            // Person selector — index 0
            _buildStaggeredChild(
              0,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.person,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 8),
                  _buildPersonSelector(theme, l10n),
                  if (_personError != null)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                          top: 4, start: 12),
                      child: Text(
                        _personError!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Transaction type — index 1
            _buildStaggeredChild(
              1,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.type,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 8),
                  _buildTypeSelector(l10n, typeColor),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Amount — index 2
            _buildStaggeredChild(
              2,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.amount,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
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
                      prefixIcon:
                          Icon(Icons.attach_money, color: typeColor),
                      hintText: '0.00',
                      hintStyle: TextStyle(
                        color: typeColor.withOpacity(0.3),
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.amountRequired;
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return l10n.amountGreaterThanZero;
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Date — index 3
            _buildStaggeredChild(
              3,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.date,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 8),
                  _DatePickerTile(
                    label: l10n.transactionDate,
                    date: _date,
                    onDateSelected: (date) =>
                        setState(() => _date = date),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Due date — index 4
            _buildStaggeredChild(
              4,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.dueDateOptional,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 8),
                  _DatePickerTile(
                    label: _dueDate == null
                        ? l10n.setDueDate
                        : l10n.dueDate,
                    date: _dueDate,
                    onDateSelected: (date) =>
                        setState(() => _dueDate = date),
                    onClear: _dueDate != null
                        ? () => setState(() => _dueDate = null)
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Note — index 5
            _buildStaggeredChild(
              5,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.note,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: l10n.addNote,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Save button — index 6
            _buildStaggeredChild(
              6,
              _buildSaveButton(l10n, typeColor),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonSelector(ThemeData theme, AppLocalizations l10n) {
    return InkWell(
      onTap: _showContactPicker,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _selectedPerson != null
              ? AppTheme.primaryColor.withOpacity(0.05)
              : const Color(0xFFF0F4FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _personError != null
                ? theme.colorScheme.error
                : _selectedPerson != null
                    ? AppTheme.primaryColor.withOpacity(0.3)
                    : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            if (_selectedPerson != null) ...[
              _buildPersonAvatar(_selectedPerson!.name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedPerson!.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_selectedPerson!.phoneNumber != null)
                      Text(
                        _selectedPerson!.phoneNumber!,
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              Icon(Icons.swap_horiz, color: theme.colorScheme.outline),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_add_outlined,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.selectPerson,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPersonAvatar(String name) {
    final initials = name.isNotEmpty
        ? name
            .split(' ')
            .where((w) => w.isNotEmpty)
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join()
        : '?';

    final gradientColors = AppTheme.avatarGradient(name);

    return Hero(
      tag: 'avatar_add_$name',
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
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

  Widget _buildSaveButton(AppLocalizations l10n, Color typeColor) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _isSaved
          ? Container(
              key: const ValueKey('saved'),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 400),
                curve: Curves.elasticOut,
                builder: (context, value, _) {
                  return Transform.scale(
                    scale: value,
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.loanColor,
                      size: 48,
                    ),
                  );
                },
              ),
            )
          : SizedBox(
              key: const ValueKey('button'),
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: typeColor,
                ),
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(l10n.saveTransaction),
              ),
            ),
    );
  }

  void _showContactPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => ContactPickerWidget(
          onPersonSelected: (person) {
            setState(() {
              _selectedPerson = person;
              _personError = null;
            });
          },
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_selectedPerson == null) {
      setState(() => _personError =
          AppLocalizations.of(context)!.personRequired);
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final useCase = ref.read(addTransactionUseCaseProvider);
      final amount = double.parse(_amountController.text);
      final note =
          _noteController.text.isEmpty ? null : _noteController.text;

      await useCase.execute(
        person: _selectedPerson!,
        type: _type,
        amount: amount,
        date: _date,
        dueDate: _dueDate,
        note: note,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSaved = true;
        });

        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.transactionSaved),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }
}

/// Animated type chip
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
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                key: ValueKey(isSelected),
                color: isSelected ? color : Colors.grey,
                size: 20,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
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

/// Animated date picker tile
class _DatePickerTile extends StatelessWidget {
  const _DatePickerTile({
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
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    final dateFormat = locale.languageCode == 'ar'
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
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: date != null
              ? AppTheme.primaryColor.withOpacity(0.05)
              : const Color(0xFFF0F4FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: date != null
                ? AppTheme.primaryColor.withOpacity(0.2)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 20,
              color: date != null
                  ? AppTheme.primaryColor
                  : theme.colorScheme.outline,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                date != null ? dateFormat.format(date!) : label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: date == null ? theme.colorScheme.outline : null,
                  fontWeight: date != null ? FontWeight.w500 : null,
                ),
              ),
            ),
            if (onClear != null)
              IconButton(
                icon: const Icon(Icons.clear_rounded, size: 18),
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
