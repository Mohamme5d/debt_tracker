import 'package:flutter/material.dart';
import 'package:raseed/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme.dart';
import '../../../core/db/models/debt_transaction.dart';
import '../../../core/db/models/enums.dart';
import '../../../core/widgets/amount_display.dart';
import '../../../shared/widgets/gradient_card.dart';
import '../../../shared/widgets/person_avatar.dart';
import '../../../features/export/pdf_export_service.dart';
import '../providers/transaction_provider.dart';

class PersonTransactionsScreen extends ConsumerStatefulWidget {
  const PersonTransactionsScreen({super.key, required this.personId});

  final int personId;

  @override
  ConsumerState<PersonTransactionsScreen> createState() =>
      _PersonTransactionsScreenState();
}

class _PersonTransactionsScreenState
    extends ConsumerState<PersonTransactionsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _headerAnimController;
  late final AnimationController _listAnimController;
  int _filterIndex = 0;

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
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _listAnimController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    _listAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final txAsync =
        ref.watch(transactionsForPersonProvider(widget.personId));
    final personAsync = ref.watch(personByIdProvider(widget.personId));

    final personName = personAsync.when(
      data: (p) => p?.name ?? '',
      loading: () => '',
      error: (_, __) => '',
    );

    final filters = [l10n.all, l10n.active, l10n.settled, l10n.overdue];

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        title: Text(personName.isNotEmpty
            ? l10n.transactionsFor(personName)
            : l10n.transactions),
        actions: [
          txAsync.whenOrNull(
                data: (transactions) => transactions.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.picture_as_pdf_rounded),
                        tooltip: l10n.exportPdf,
                        onPressed: () => _exportPdf(transactions, personAsync.valueOrNull, l10n, context),
                      )
                    : null,
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: txAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_rounded,
                      size: 64, color: Colors.white.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noTransactions,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          // Compute summary
          double totalDebt = 0;
          double totalLoan = 0;
          for (final tx in transactions) {
            if (tx.type == TransactionType.debt) {
              totalDebt += tx.remaining;
            } else {
              totalLoan += tx.remaining;
            }
          }

          final filtered = _applyFilter(transactions);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Person header card
              FadeTransition(
                opacity: _headerAnimController,
                child: GradientCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      PersonAvatar(
                        name: personName,
                        size: 56,
                        heroTag: 'avatar_${widget.personId}',
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              personName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${transactions.length} ${l10n.transactions}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (totalDebt > 0)
                            Text(
                              '-${AmountDisplay.format(totalDebt)}',
                              style: const TextStyle(
                                color: AppTheme.debtColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          if (totalLoan > 0)
                            Text(
                              '+${AmountDisplay.format(totalLoan)}',
                              style: const TextStyle(
                                color: AppTheme.loanColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Filter tabs
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  itemBuilder: (context, index) {
                    final selected = _filterIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _filterIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsetsDirectional.only(end: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppTheme.primaryColor.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? AppTheme.primaryColor
                                : AppTheme.borderDark,
                          ),
                        ),
                        child: Text(
                          filters[index],
                          style: TextStyle(
                            color: selected
                                ? AppTheme.primaryColor
                                : Colors.white.withOpacity(0.5),
                            fontSize: 12,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Transaction list
              ...List.generate(
                filtered.length,
                (index) =>
                    _buildTransactionCard(filtered[index], index, l10n),
              ),

              const SizedBox(height: 100),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child:
              Text('Error: $e', style: const TextStyle(color: Colors.white)),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.push('/add-transaction?personId=${widget.personId}'),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addTransaction),
      ),
    );
  }

  Future<void> _exportPdf(
    List<DebtTransaction> transactions,
    dynamic person,
    AppLocalizations l10n,
    BuildContext ctx,
  ) async {
    final isArabic = Localizations.localeOf(ctx).languageCode == 'ar';
    try {
      final service = PdfExportService();
      final bytes = await service.generateTransactionReport(
        transactions: transactions,
        person: person,
        l10n: l10n,
        isArabic: isArabic,
      );
      await service.sharePdf(bytes, 'raseed_${person?.name ?? 'report'}.pdf');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  List<DebtTransaction> _applyFilter(List<DebtTransaction> transactions) {
    switch (_filterIndex) {
      case 1:
        return transactions
            .where((tx) => tx.status == TransactionStatus.active)
            .toList();
      case 2:
        return transactions
            .where((tx) => tx.status == TransactionStatus.settled)
            .toList();
      case 3:
        return transactions
            .where((tx) => tx.status == TransactionStatus.overdue)
            .toList();
      default:
        return transactions;
    }
  }

  Widget _buildTransactionCard(
      DebtTransaction tx, int index, AppLocalizations l10n) {
    final isDebt = tx.type == TransactionType.debt;
    final color = isDebt ? AppTheme.debtColor : AppTheme.loanColor;
    final typeLabel = isDebt ? l10n.debt : l10n.loan;
    final progress =
        tx.amount > 0 ? (tx.amountPaid / tx.amount).clamp(0.0, 1.0) : 0.0;

    final locale = Localizations.localeOf(context);
    final dateFormat = locale.languageCode == 'ar'
        ? DateFormat('yyyy/MM/dd', 'ar')
        : DateFormat('MMM dd, yyyy');

    Color statusColor;
    String statusLabel;
    switch (tx.status) {
      case TransactionStatus.settled:
        statusColor = AppTheme.settledColor;
        statusLabel = l10n.settled;
        break;
      case TransactionStatus.overdue:
        statusColor = AppTheme.overdueColor;
        statusLabel = l10n.overdue;
        break;
      default:
        statusColor = AppTheme.primaryColor;
        statusLabel = l10n.active;
    }

    final start = (index * 0.06).clamp(0.0, 0.7);
    final end = (start + 0.5).clamp(start + 0.1, 1.0);

    final fadeAnim = CurvedAnimation(
      parent: _listAnimController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: fadeAnim,
      child: Dismissible(
        key: ValueKey(tx.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: AlignmentDirectional.centerEnd,
          padding: const EdgeInsetsDirectional.only(end: 20),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppTheme.debtColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Icons.delete_rounded, color: AppTheme.debtColor),
        ),
        confirmDismiss: (_) async {
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
          await ref.read(deleteTransactionProvider(tx.id).future);
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push('/transaction/${tx.id}'),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.glassCardDecoration,
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            typeLabel,
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          AmountDisplay.format(tx.amount),
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    if (tx.status != TransactionStatus.settled) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4,
                          backgroundColor:
                              AppTheme.borderDark.withOpacity(0.3),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${l10n.remaining}: ${AmountDisplay.format(tx.remaining)}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            dateFormat.format(tx.date),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dateFormat.format(tx.date),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 11,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  size: 14,
                                  color: AppTheme.loanColor
                                      .withOpacity(0.7)),
                              const SizedBox(width: 4),
                              Text(
                                l10n.settled,
                                style: TextStyle(
                                  color: AppTheme.loanColor
                                      .withOpacity(0.7),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                    if (tx.dueDate != null &&
                        tx.status != TransactionStatus.settled) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.event_rounded,
                              size: 12,
                              color: tx.status ==
                                      TransactionStatus.overdue
                                  ? AppTheme.overdueColor
                                  : Colors.white.withOpacity(0.4)),
                          const SizedBox(width: 4),
                          Text(
                            '${l10n.due}: ${dateFormat.format(tx.dueDate!)}',
                            style: TextStyle(
                              color: tx.status ==
                                      TransactionStatus.overdue
                                  ? AppTheme.overdueColor
                                  : Colors.white.withOpacity(0.4),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
