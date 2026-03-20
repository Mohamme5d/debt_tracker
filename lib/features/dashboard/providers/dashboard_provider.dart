import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/db/isar_service.dart';
import '../../../core/db/models/debt_transaction.dart';
import '../../../core/db/models/enums.dart';
import '../../../core/db/models/person.dart';
import '../../../core/db/transaction_utils.dart';

part 'dashboard_provider.g.dart';

class DashboardSummary {
  final double totalIOwe;
  final double totalOwedToMe;
  final List<PersonBalance> personBalances;
  final List<DebtTransaction> allTransactions;

  const DashboardSummary({
    required this.totalIOwe,
    required this.totalOwedToMe,
    required this.personBalances,
    required this.allTransactions,
  });
}

class PersonBalance {
  final Person person;
  final double netBalance;
  final int activeCount;
  final double totalAmount;
  final double totalPaid;
  final DateTime? lastTransactionDate;

  const PersonBalance({
    required this.person,
    required this.netBalance,
    required this.activeCount,
    required this.totalAmount,
    required this.totalPaid,
    this.lastTransactionDate,
  });

  double get progressRatio =>
      totalAmount > 0 ? (totalPaid / totalAmount).clamp(0.0, 1.0) : 0.0;
}

@riverpod
Stream<DashboardSummary> dashboardSummary(Ref ref) async* {
  final db = ref.watch(isarProvider);

  yield await _computeSummary(db);

  await for (final _ in db.debtTransactions.watchLazy()) {
    yield await _computeSummary(db);
  }
}

Future<DashboardSummary> _computeSummary(Isar db) async {
  // Ensure overdue status is up-to-date before computing balances
  await syncOverdueStatus(db);

  final allTransactions = await db.debtTransactions.where().findAll();

  final activeTransactions = allTransactions
      .where((tx) =>
          tx.status == TransactionStatus.active ||
          tx.status == TransactionStatus.overdue)
      .toList();

  double totalIOwe = 0;
  double totalOwedToMe = 0;

  final Map<int, _PersonAccumulator> personMap = {};

  for (final tx in activeTransactions) {
    await tx.person.load();
    final person = tx.person.value;
    if (person == null) continue;

    final remaining = tx.remaining;

    if (tx.type == TransactionType.debt) {
      totalIOwe += remaining;
      personMap.putIfAbsent(
        person.id,
        () => _PersonAccumulator(person: person),
      );
      personMap[person.id]!.netBalance -= remaining;
      personMap[person.id]!.activeCount++;
      personMap[person.id]!.totalAmount += tx.amount;
      personMap[person.id]!.totalPaid += tx.amountPaid;
      if (personMap[person.id]!.lastDate == null ||
          tx.date.isAfter(personMap[person.id]!.lastDate!)) {
        personMap[person.id]!.lastDate = tx.date;
      }
    } else {
      totalOwedToMe += remaining;
      personMap.putIfAbsent(
        person.id,
        () => _PersonAccumulator(person: person),
      );
      personMap[person.id]!.netBalance += remaining;
      personMap[person.id]!.activeCount++;
      personMap[person.id]!.totalAmount += tx.amount;
      personMap[person.id]!.totalPaid += tx.amountPaid;
      if (personMap[person.id]!.lastDate == null ||
          tx.date.isAfter(personMap[person.id]!.lastDate!)) {
        personMap[person.id]!.lastDate = tx.date;
      }
    }
  }

  // Load person links for all transactions
  for (final tx in allTransactions) {
    if (tx.person.value == null) {
      await tx.person.load();
    }
  }

  final personBalances = personMap.values
      .map(
        (acc) => PersonBalance(
          person: acc.person,
          netBalance: acc.netBalance,
          activeCount: acc.activeCount,
          totalAmount: acc.totalAmount,
          totalPaid: acc.totalPaid,
          lastTransactionDate: acc.lastDate,
        ),
      )
      .toList()
    ..sort((a, b) => b.netBalance.abs().compareTo(a.netBalance.abs()));

  return DashboardSummary(
    totalIOwe: totalIOwe,
    totalOwedToMe: totalOwedToMe,
    personBalances: personBalances,
    allTransactions: allTransactions,
  );
}

class _PersonAccumulator {
  final Person person;
  double netBalance = 0;
  int activeCount = 0;
  double totalAmount = 0;
  double totalPaid = 0;
  DateTime? lastDate;

  _PersonAccumulator({required this.person});
}
