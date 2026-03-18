import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/db/isar_service.dart';
import '../../../core/db/models/debt_transaction.dart';
import '../../../core/db/models/enums.dart';
import '../../../core/db/models/person.dart';

part 'dashboard_provider.g.dart';

class DashboardSummary {
  final double totalIOwe;
  final double totalOwedToMe;
  final List<PersonBalance> personBalances;

  const DashboardSummary({
    required this.totalIOwe,
    required this.totalOwedToMe,
    required this.personBalances,
  });
}

class PersonBalance {
  final Person person;
  final double netBalance; // positive = they owe me, negative = I owe them
  final int activeCount;

  const PersonBalance({
    required this.person,
    required this.netBalance,
    required this.activeCount,
  });
}

@riverpod
Stream<DashboardSummary> dashboardSummary(Ref ref) async* {
  final db = ref.watch(isarProvider);

  // Emit initial value then watch for changes
  yield await _computeSummary(db);

  await for (final _ in db.debtTransactions.watchLazy()) {
    yield await _computeSummary(db);
  }
}

Future<DashboardSummary> _computeSummary(Isar db) async {
  final transactions = await db.debtTransactions
      .filter()
      .statusEqualTo(TransactionStatus.active)
      .or()
      .statusEqualTo(TransactionStatus.overdue)
      .findAll();

  double totalIOwe = 0;
  double totalOwedToMe = 0;

  final Map<int, _PersonAccumulator> personMap = {};

  for (final tx in transactions) {
    await tx.person.load();
    final person = tx.person.value;
    if (person == null) continue;

    final remaining = tx.remaining;

    // Check overdue
    if (tx.dueDate != null &&
        tx.dueDate!.isBefore(DateTime.now()) &&
        tx.status == TransactionStatus.active) {
      tx.status = TransactionStatus.overdue;
      await db.writeTxn(() => db.debtTransactions.put(tx));
    }

    if (tx.type == TransactionType.debt) {
      // I owe someone
      totalIOwe += remaining;
      personMap.putIfAbsent(
        person.id,
        () => _PersonAccumulator(person: person),
      );
      personMap[person.id]!.netBalance -= remaining;
      personMap[person.id]!.activeCount++;
    } else {
      // Someone owes me (loan)
      totalOwedToMe += remaining;
      personMap.putIfAbsent(
        person.id,
        () => _PersonAccumulator(person: person),
      );
      personMap[person.id]!.netBalance += remaining;
      personMap[person.id]!.activeCount++;
    }
  }

  final personBalances = personMap.values
      .map(
        (acc) => PersonBalance(
          person: acc.person,
          netBalance: acc.netBalance,
          activeCount: acc.activeCount,
        ),
      )
      .toList()
    ..sort((a, b) => b.netBalance.abs().compareTo(a.netBalance.abs()));

  return DashboardSummary(
    totalIOwe: totalIOwe,
    totalOwedToMe: totalOwedToMe,
    personBalances: personBalances,
  );
}

class _PersonAccumulator {
  final Person person;
  double netBalance = 0;
  int activeCount = 0;

  _PersonAccumulator({required this.person});
}
