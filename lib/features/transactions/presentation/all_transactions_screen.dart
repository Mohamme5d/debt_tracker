import 'package:flutter/material.dart';
import 'package:raseed/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/theme.dart';
import '../../../core/db/isar_service.dart';
import '../../../core/db/models/debt_transaction.dart';
import '../../../core/db/models/enums.dart';
import '../../../shared/widgets/gradient_card.dart';
import '../../../shared/widgets/person_avatar.dart';
import '../../../core/widgets/amount_display.dart';

part 'all_transactions_screen.g.dart';

@riverpod
Stream<List<DebtTransaction>> allTransactions(Ref ref) async* {
  final db = ref.watch(isarProvider);

  List<DebtTransaction> load() {
    final all = db.debtTransactions.where().sortByDateDesc().findAllSync();
    for (final tx in all) {
      tx.person.loadSync();
    }
    return all;
  }

  yield load();

  await for (final _ in db.debtTransactions.watchLazy()) {
    yield load();
  }
}

class AllTransactionsScreen extends ConsumerStatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  ConsumerState<AllTransactionsScreen> createState() =>
      _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends ConsumerState<AllTransactionsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _listAnimController;
  int _filterIndex = 0; // 0=All, 1=Active, 2=Settled, 3=Overdue

  @override
  void initState() {
    super.initState();
    _listAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _listAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final txAsync = ref.watch(allTransactionsProvider);

    final filters = [l10n.all, l10n.active, l10n.settled, l10n.overdue];

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        title: Text(l10n.allTransactions),
      ),
      body: Column(
        children: [
          // Filter tabs
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
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
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          Expanded(
            child: txAsync.when(
              data: (transactions) {
                final filtered = _applyFilter(transactions);
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long_rounded,
                            size: 64,
                            color: Colors.white.withOpacity(0.2)),
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

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _buildTransactionTile(
                        filtered[index], index, l10n);
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Error: $e',
                    style: const TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-transaction'),
        child: const Icon(Icons.add_rounded),
      ),
    );
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

  Widget _buildTransactionTile(
      DebtTransaction tx, int index, AppLocalizations l10n) {
    final isDebt = tx.type == TransactionType.debt;
    final color = isDebt ? AppTheme.debtColor : AppTheme.loanColor;
    final typeLabel = isDebt ? l10n.debt : l10n.loan;
    final personName = tx.person.value?.name ?? '-';
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

    return Padding(
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
                    PersonAvatar(name: personName, size: 42, fontSize: 15),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            personName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dateFormat.format(tx.date),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          AmountDisplay.format(tx.amount),
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                typeLabel,
                                style: TextStyle(
                                  color: color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                statusLabel,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                if (tx.status != TransactionStatus.settled) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 3,
                      backgroundColor: AppTheme.borderDark.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  const SizedBox(height: 4),
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
                      if (tx.dueDate != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.event_rounded,
                                size: 12,
                                color: tx.status ==
                                        TransactionStatus.overdue
                                    ? AppTheme.overdueColor
                                    : Colors.white.withOpacity(0.4)),
                            const SizedBox(width: 4),
                            Text(
                              dateFormat.format(tx.dueDate!),
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
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
