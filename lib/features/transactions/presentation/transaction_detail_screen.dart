import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme.dart';
import '../../../core/db/models/enums.dart';
import '../../../core/db/models/payment.dart';
import '../../../core/widgets/amount_display.dart';
import '../providers/transaction_provider.dart';

class TransactionDetailScreen extends ConsumerStatefulWidget {
  const TransactionDetailScreen({super.key, required this.transactionId});

  final int transactionId;

  @override
  ConsumerState<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState
    extends ConsumerState<TransactionDetailScreen>
    with TickerProviderStateMixin {
  late final AnimationController _headerAnimController;
  late final AnimationController _listAnimController;
  late final AnimationController _progressAnimController;

  @override
  void initState() {
    super.initState();
    _headerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _listAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _progressAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _progressAnimController.forward();
        _listAnimController.forward();
      }
    });
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    _listAnimController.dispose();
    _progressAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(transactionByIdProvider(widget.transactionId));
    final paymentsAsync =
        ref.watch(paymentsForTransactionProvider(widget.transactionId));
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    final dateFormat = locale.languageCode == 'ar'
        ? DateFormat('yyyy/MM/dd', 'ar')
        : DateFormat('MMM dd, yyyy');

    return txAsync.when(
      data: (tx) {
        if (tx == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.transaction)),
            body: Center(child: Text(l10n.notFound)),
          );
        }

        final person = tx.person.value;
        final isDebt = tx.type == TransactionType.debt;
        final typeColor = isDebt ? AppTheme.debtColor : AppTheme.loanColor;
        final typeLabel = isDebt ? l10n.debt : l10n.loan;
        final progress =
            tx.amount > 0 ? (tx.amountPaid / tx.amount).clamp(0.0, 1.0) : 0.0;

        final isOverdue = tx.dueDate != null &&
            tx.dueDate!.isBefore(DateTime.now()) &&
            tx.status == TransactionStatus.active;

        final isSettled = tx.status == TransactionStatus.settled;

        return Scaffold(
          backgroundColor: AppTheme.surfaceColor,
          appBar: AppBar(
            title: Text(person?.name ?? ''),
            actions: [
              if (!isSettled)
                PopupMenuButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'settle',
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, size: 20),
                          const SizedBox(width: 8),
                          Text(l10n.markSettled),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline,
                              size: 20, color: AppTheme.debtColor),
                          const SizedBox(width: 8),
                          Text(l10n.delete,
                              style: TextStyle(color: AppTheme.debtColor)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'settle') {
                      await ref.read(
                        markAsSettledProvider(widget.transactionId).future,
                      );
                    } else if (value == 'delete') {
                      final confirmed = await _confirmDelete(context, l10n);
                      if (confirmed && context.mounted) {
                        await ref.read(
                          deleteTransactionProvider(widget.transactionId)
                              .future,
                        );
                        if (context.mounted) context.pop();
                      }
                    }
                  },
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header card with animations
              FadeTransition(
                opacity: _headerAnimController,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _headerAnimController,
                    curve: Curves.easeOutCubic,
                  )),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color ?? Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: typeColor.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Type badge + status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: typeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                typeLabel,
                                style: TextStyle(
                                  color: typeColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            _AnimatedStatusBadge(
                              status: tx.status,
                              isOverdue: isOverdue,
                              l10n: l10n,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Animated amount
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: tx.amount),
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.easeOutCubic,
                          builder: (context, val, _) {
                            return Text(
                              NumberFormat('#,##0.00').format(val),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: typeColor,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Animated progress bar
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${l10n.paid}: ${AmountDisplay.format(tx.amountPaid)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${l10n.remaining}: ${AmountDisplay.format(tx.remaining)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: AnimatedBuilder(
                                animation: _progressAnimController,
                                builder: (context, _) {
                                  final t = Curves.easeOutCubic.transform(
                                      _progressAnimController.value);
                                  return LinearProgressIndicator(
                                    value: progress * t,
                                    minHeight: 10,
                                    backgroundColor: theme.colorScheme
                                        .surfaceContainerHighest,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                            typeColor),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 6),
                            AnimatedBuilder(
                              animation: _progressAnimController,
                              builder: (context, _) {
                                final t = Curves.easeOutCubic.transform(
                                    _progressAnimController.value);
                                final percent =
                                    (progress * 100 * t).toInt();
                                return Text(
                                  '$percent%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: typeColor,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Date info
                        _InfoRow(
                          icon: Icons.calendar_today_rounded,
                          label:
                              '${l10n.created}: ${dateFormat.format(tx.date)}',
                        ),
                        if (tx.dueDate != null) ...[
                          const SizedBox(height: 6),
                          _InfoRow(
                            icon: Icons.event_rounded,
                            label:
                                '${l10n.due}: ${dateFormat.format(tx.dueDate!)}',
                            color: isOverdue ? AppTheme.debtColor : null,
                            trailing: isOverdue
                                ? _OverduePulse(l10n: l10n)
                                : null,
                          ),
                        ],

                        // Note
                        if (tx.note != null && tx.note!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.note_rounded,
                                size: 16,
                                color: theme.colorScheme.outline,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  tx.note!,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ],

                        // Settled celebration
                        if (isSettled) ...[
                          const SizedBox(height: 20),
                          _SettledCelebration(l10n: l10n),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Payments section header
              FadeTransition(
                opacity: _listAnimController,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 4),
                  child: Text(
                    l10n.payments,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              paymentsAsync.when(
                data: (payments) {
                  if (payments.isEmpty) {
                    return FadeTransition(
                      opacity: _listAnimController,
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color ?? Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.payments_outlined,
                                size: 44,
                                color: theme.colorScheme.outline
                                    .withOpacity(0.5),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.noPaymentsYet,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: List.generate(payments.length, (index) {
                      final payment = payments[index];
                      return _AnimatedPaymentTile(
                        payment: payment,
                        index: index,
                        controller: _listAnimController,
                        l10n: l10n,
                        dateFormat: dateFormat,
                        onDelete: () async {
                          final useCase =
                              ref.read(recordPaymentUseCaseProvider);
                          await useCase.deletePayment(
                            payment: payment,
                            transaction: tx,
                          );
                        },
                      );
                    }),
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
              ),
              const SizedBox(height: 100),
            ],
          ),
          floatingActionButton: !isSettled
              ? ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _headerAnimController,
                    curve:
                        const Interval(0.5, 1.0, curve: Curves.elasticOut),
                  ),
                  child: FloatingActionButton.extended(
                    onPressed: () =>
                        _showAddPaymentSheet(context, ref, tx, l10n),
                    icon: const Icon(Icons.add_rounded),
                    label: Text(l10n.addPayment),
                  ),
                )
              : null,
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.transaction)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.transaction)),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<bool> _confirmDelete(
      BuildContext context, AppLocalizations l10n) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(l10n.deleteTransaction),
            content: Text(l10n.deleteTransactionConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style:
                    FilledButton.styleFrom(backgroundColor: AppTheme.debtColor),
                child: Text(l10n.delete),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showAddPaymentSheet(
    BuildContext context,
    WidgetRef ref,
    dynamic tx,
    AppLocalizations l10n,
  ) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.recordPayment,
                  style:
                      Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${l10n.remaining}: ${AmountDisplay.format(tx.remaining)}',
                  style:
                      Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(sheetContext).colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.amount,
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.enterAnAmount;
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return l10n.mustBeGreaterThanZero;
                    }
                    if (amount > tx.remaining) {
                      return '${l10n.cannotExceedRemaining} (${tx.remaining.toStringAsFixed(2)})';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: noteController,
                  decoration: InputDecoration(
                    labelText: l10n.paymentNote,
                    prefixIcon: const Icon(Icons.note_rounded),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;

                      final useCase =
                          ref.read(recordPaymentUseCaseProvider);
                      final amount =
                          double.parse(amountController.text);
                      final note = noteController.text.isEmpty
                          ? null
                          : noteController.text;

                      try {
                        await useCase.execute(
                          transaction: tx,
                          amount: amount,
                          note: note,
                        );
                        if (sheetContext.mounted) {
                          Navigator.pop(sheetContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.paymentAdded),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (sheetContext.mounted) {
                          ScaffoldMessenger.of(sheetContext).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: Text(l10n.save),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Info row for dates
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    this.color,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final Color? color;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.outline;

    return Row(
      children: [
        Icon(icon, size: 16, color: effectiveColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: effectiveColor,
              fontWeight: color != null ? FontWeight.w600 : null,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Animated status badge
class _AnimatedStatusBadge extends StatelessWidget {
  const _AnimatedStatusBadge({
    required this.status,
    required this.isOverdue,
    required this.l10n,
  });

  final TransactionStatus status;
  final bool isOverdue;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor;
    final Color foregroundColor;
    final String label;

    if (isOverdue || status == TransactionStatus.overdue) {
      backgroundColor = Colors.red.shade50;
      foregroundColor = Colors.red.shade700;
      label = l10n.overdue;
    } else if (status == TransactionStatus.settled) {
      backgroundColor = Colors.green.shade50;
      foregroundColor = Colors.green.shade700;
      label = l10n.settled;
    } else {
      backgroundColor = Colors.blue.shade50;
      foregroundColor = Colors.blue.shade700;
      label = l10n.active;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foregroundColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Overdue pulse indicator
class _OverduePulse extends StatefulWidget {
  const _OverduePulse({required this.l10n});

  final AppLocalizations l10n;

  @override
  State<_OverduePulse> createState() => _OverduePulseState();
}

class _OverduePulseState extends State<_OverduePulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.5, end: 1.0).animate(_controller),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          widget.l10n.overdue.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.red.shade700,
          ),
        ),
      ),
    );
  }
}

/// Animated payment tile
class _AnimatedPaymentTile extends StatelessWidget {
  const _AnimatedPaymentTile({
    required this.payment,
    required this.index,
    required this.controller,
    required this.l10n,
    required this.dateFormat,
    required this.onDelete,
  });

  final Payment payment;
  final int index;
  final AnimationController controller;
  final AppLocalizations l10n;
  final DateFormat dateFormat;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final start = (index * 0.08).clamp(0.0, 0.6);
    final end = (start + 0.5).clamp(start + 0.1, 1.0);

    final fadeAnim = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOut),
    );

    final slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    ));

    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: slideAnim,
        child: Dismissible(
          key: ValueKey(payment.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: AlignmentDirectional.centerEnd,
            padding: const EdgeInsetsDirectional.only(end: 20),
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.delete_rounded, color: Colors.red.shade700),
          ),
          confirmDismiss: (_) async {
            return await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text(l10n.deletePayment),
                    content: Text(l10n.deletePaymentConfirm),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(l10n.cancel),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.debtColor),
                        child: Text(l10n.delete),
                      ),
                    ],
                  ),
                ) ??
                false;
          },
          onDismissed: (_) => onDelete(),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: theme.cardTheme.color ?? Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.loanColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.payment_rounded,
                  color: AppTheme.loanColor,
                  size: 20,
                ),
              ),
              title: Text(
                AmountDisplay.format(payment.amount),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.loanColor,
                ),
              ),
              subtitle: Text(
                dateFormat.format(payment.date),
                style: theme.textTheme.bodySmall,
              ),
              trailing: payment.note != null && payment.note!.isNotEmpty
                  ? Tooltip(
                      message: payment.note!,
                      child: Icon(
                        Icons.note_rounded,
                        size: 18,
                        color: theme.colorScheme.outline,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

/// Settled celebration animation
class _SettledCelebration extends StatefulWidget {
  const _SettledCelebration({required this.l10n});

  final AppLocalizations l10n;

  @override
  State<_SettledCelebration> createState() => _SettledCelebrationState();
}

class _SettledCelebrationState extends State<_SettledCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
      child: FadeTransition(
        opacity: _controller,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.loanColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.loanColor.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: AppTheme.loanColor,
                size: 28,
              ),
              const SizedBox(width: 10),
              Text(
                widget.l10n.settled_status,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.loanColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
