import 'dart:io';

import 'package:flutter/material.dart';
import 'package:raseed/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme.dart';
import '../../../core/db/models/enums.dart';
import '../../../core/db/models/payment.dart';
import '../../../core/widgets/amount_display.dart';
import '../../../core/widgets/attachment_section.dart';
import '../../../shared/widgets/gradient_card.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    final dateFormat = locale.languageCode == 'ar'
        ? DateFormat('yyyy/MM/dd', 'ar')
        : DateFormat('MMM dd, yyyy');

    return txAsync.when(
      data: (tx) {
        if (tx == null) {
          return Scaffold(
            backgroundColor: AppTheme.backgroundDark,
            appBar: AppBar(title: Text(l10n.transaction)),
            body: Center(
              child: Text(l10n.notFound,
                  style: const TextStyle(color: Colors.white)),
            ),
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
          backgroundColor: AppTheme.backgroundDark,
          appBar: AppBar(
            backgroundColor: AppTheme.backgroundDark,
            title: Text(person?.name ?? ''),
            actions: [
              PopupMenuButton(
                color: AppTheme.surfaceDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit_rounded, size: 20,
                            color: Colors.white),
                        const SizedBox(width: 8),
                        Text(l10n.edit,
                            style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  if (!isSettled)
                    PopupMenuItem(
                      value: 'settle',
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, size: 20,
                              color: Colors.white),
                          const SizedBox(width: 8),
                          Text(l10n.markSettled,
                              style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline,
                            size: 20, color: AppTheme.debtColor),
                        const SizedBox(width: 8),
                        Text(l10n.delete,
                            style:
                                const TextStyle(color: AppTheme.debtColor)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) async {
                  if (value == 'edit') {
                    context.push('/edit-transaction/${widget.transactionId}');
                  } else if (value == 'settle') {
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
              // Header card
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
                  child: GradientCard(
                    padding: const EdgeInsets.all(24),
                    gradient: LinearGradient(
                      begin: AlignmentDirectional.topStart,
                      end: AlignmentDirectional.bottomEnd,
                      colors: [
                        typeColor.withOpacity(0.12),
                        AppTheme.surfaceDark2,
                      ],
                    ),
                    borderColor: typeColor.withOpacity(0.2),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: typeColor.withOpacity(0.15),
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
                            _statusBadge(tx.status, isOverdue, l10n),
                          ],
                        ),
                        const SizedBox(height: 24),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: tx.amount),
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.easeOutCubic,
                          builder: (context, val, _) {
                            return Text(
                              NumberFormat('#,##0.00').format(val),
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                color: typeColor,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        // Progress
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${l10n.paid}: ${AmountDisplay.format(tx.amountPaid)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '${l10n.remaining}: ${AmountDisplay.format(tx.remaining)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 13,
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
                                    backgroundColor:
                                        AppTheme.borderDark.withOpacity(0.3),
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
                        _infoRow(
                          Icons.calendar_today_rounded,
                          '${l10n.created}: ${dateFormat.format(tx.date)}',
                        ),
                        if (tx.dueDate != null) ...[
                          const SizedBox(height: 6),
                          _infoRow(
                            Icons.event_rounded,
                            '${l10n.due}: ${dateFormat.format(tx.dueDate!)}',
                            color: isOverdue ? AppTheme.overdueColor : null,
                          ),
                        ],
                        if (tx.note != null && tx.note!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Divider(color: AppTheme.borderDark.withOpacity(0.5)),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.note_rounded,
                                  size: 16,
                                  color: Colors.white.withOpacity(0.4)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  tx.note!,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (tx.attachmentPaths.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Divider(color: AppTheme.borderDark.withOpacity(0.5)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.attach_file_rounded,
                                  size: 14,
                                  color: Colors.white.withOpacity(0.4)),
                              const SizedBox(width: 6),
                              Text(
                                Localizations.localeOf(context).languageCode == 'ar'
                                    ? 'المرفقات'
                                    : 'Attachments',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: tx.attachmentPaths.map((p) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => Scaffold(
                                        backgroundColor: Colors.black,
                                        appBar: AppBar(
                                          backgroundColor: Colors.black,
                                          iconTheme: const IconThemeData(color: Colors.white),
                                        ),
                                        body: Center(
                                          child: InteractiveViewer(
                                            child: Image.file(File(p)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: File(p).existsSync()
                                        ? Image.file(File(p),
                                            width: 72,
                                            height: 72,
                                            fit: BoxFit.cover)
                                        : Container(
                                            width: 72,
                                            height: 72,
                                            color: AppTheme.surfaceDark,
                                            child: Icon(Icons.broken_image_rounded,
                                                color: Colors.white.withOpacity(0.3)),
                                          ),
                                  ),
                                ),
                              )).toList(),
                            ),
                          ),
                        ],
                        if (isSettled) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.loanColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.loanColor.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle_rounded,
                                    color: AppTheme.loanColor, size: 28),
                                const SizedBox(width: 10),
                                Text(
                                  l10n.settled_status,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.loanColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Payments header
              FadeTransition(
                opacity: _listAnimController,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 4),
                  child: Text(
                    l10n.payments,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
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
                      child: GradientCard(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.payments_outlined,
                                  size: 44,
                                  color: Colors.white.withOpacity(0.2)),
                              const SizedBox(height: 8),
                              Text(
                                l10n.noPaymentsYet,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
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
                      return _paymentTile(
                          payments[index], index, l10n, dateFormat, tx);
                    }),
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e',
                    style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 100),
            ],
          ),
          floatingActionButton: !isSettled
              ? ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _headerAnimController,
                    curve: const Interval(0.5, 1.0,
                        curve: Curves.elasticOut),
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
        backgroundColor: AppTheme.backgroundDark,
        appBar: AppBar(title: Text(l10n.transaction)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        appBar: AppBar(title: Text(l10n.transaction)),
        body: Center(
          child: Text('Error: $e',
              style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _statusBadge(
      TransactionStatus status, bool isOverdue, AppLocalizations l10n) {
    final Color bg;
    final Color fg;
    final String label;

    if (isOverdue || status == TransactionStatus.overdue) {
      bg = AppTheme.overdueColor.withOpacity(0.15);
      fg = AppTheme.overdueColor;
      label = l10n.overdue;
    } else if (status == TransactionStatus.settled) {
      bg = AppTheme.loanColor.withOpacity(0.15);
      fg = AppTheme.loanColor;
      label = l10n.settled;
    } else {
      bg = AppTheme.primaryColor.withOpacity(0.15);
      fg = AppTheme.primaryColor;
      label = l10n.active;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, {Color? color}) {
    final effectiveColor = color ?? Colors.white.withOpacity(0.5);
    return Row(
      children: [
        Icon(icon, size: 16, color: effectiveColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: effectiveColor,
              fontSize: 13,
              fontWeight: color != null ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _paymentTile(Payment payment, int index, AppLocalizations l10n,
      DateFormat dateFormat, dynamic tx) {
    final start = (index * 0.08).clamp(0.0, 0.6);
    final end = (start + 0.5).clamp(start + 0.1, 1.0);

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _listAnimController,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
      child: Dismissible(
        key: ValueKey(payment.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: AlignmentDirectional.centerEnd,
          padding: const EdgeInsetsDirectional.only(end: 20),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.debtColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_rounded, color: AppTheme.debtColor),
        ),
        confirmDismiss: (_) async {
          return await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(l10n.deletePayment),
                  content: Text(l10n.deletePaymentConfirm),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(l10n.cancel),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.debtColor),
                      child: Text(l10n.delete),
                    ),
                  ],
                ),
              ) ??
              false;
        },
        onDismissed: (_) async {
          final useCase = ref.read(recordPaymentUseCaseProvider);
          await useCase.deletePayment(payment: payment, transaction: tx);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: AppTheme.glassCardDecoration,
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.loanColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.payment_rounded,
                  color: AppTheme.loanColor, size: 20),
            ),
            title: Text(
              AmountDisplay.format(payment.amount),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppTheme.loanColor,
              ),
            ),
            subtitle: Text(
              dateFormat.format(payment.date),
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 12,
              ),
            ),
            trailing: payment.note != null && payment.note!.isNotEmpty
                ? Tooltip(
                    message: payment.note!,
                    child: Icon(Icons.note_rounded,
                        size: 18, color: Colors.white.withOpacity(0.3)),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(
      BuildContext context, AppLocalizations l10n) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.deleteTransaction),
            content: Text(l10n.deleteTransactionConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
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
    DateTime selectedDate = DateTime.now();
    final List<String> paymentAttachments = [];
    final locale = Localizations.localeOf(context);
    final dateFormat = locale.languageCode == 'ar'
        ? DateFormat('yyyy/MM/dd', 'ar')
        : DateFormat('MMM dd, yyyy');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
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
                        color: AppTheme.borderDark,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.recordPayment,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${l10n.remaining}: ${AmountDisplay.format(tx.remaining)}',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
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
                      color: Colors.white,
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
                  // Date picker tile
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: sheetContext,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                        builder: (ctx, child) => Theme(
                          data: Theme.of(ctx).copyWith(
                            colorScheme: ColorScheme.dark(
                              primary: AppTheme.primaryColor,
                              surface: AppTheme.surfaceDark,
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        setSheetState(() => selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.borderDark),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              color: Colors.white.withOpacity(0.5), size: 20),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.paymentDate,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                dateFormat.format(selectedDate),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Icon(Icons.edit_calendar_rounded,
                              color: AppTheme.primaryColor.withOpacity(0.7),
                              size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: noteController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: l10n.paymentNote,
                      prefixIcon: const Icon(Icons.note_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AttachmentSection(
                    paths: paymentAttachments,
                    onAdd: (p) =>
                        setSheetState(() => paymentAttachments.add(p)),
                    onRemove: (p) =>
                        setSheetState(() => paymentAttachments.remove(p)),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;

                        final useCase = ref.read(recordPaymentUseCaseProvider);
                        final amount = double.parse(amountController.text);
                        final note = noteController.text.isEmpty
                            ? null
                            : noteController.text;

                        try {
                          await useCase.execute(
                            transaction: tx,
                            amount: amount,
                            note: note,
                            date: selectedDate,
                            attachmentPaths: paymentAttachments,
                          );
                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.paymentAdded)),
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
      ),
    );
  }
}
