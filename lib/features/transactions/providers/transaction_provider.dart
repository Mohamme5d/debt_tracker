import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/db/isar_service.dart';
import '../../../core/db/models/debt_transaction.dart';
import '../../../core/db/models/enums.dart';
import '../../../core/db/models/payment.dart';
import '../../../core/db/models/person.dart';
import '../usecases/add_transaction.dart';
import '../usecases/record_payment.dart';

part 'transaction_provider.g.dart';

@riverpod
AddTransactionUseCase addTransactionUseCase(Ref ref) {
  return AddTransactionUseCase(ref.watch(isarProvider));
}

@riverpod
RecordPaymentUseCase recordPaymentUseCase(Ref ref) {
  return RecordPaymentUseCase(ref.watch(isarProvider));
}

@riverpod
Stream<DebtTransaction?> transactionById(Ref ref, int id) async* {
  final db = ref.watch(isarProvider);

  DebtTransaction? load() {
    final tx = db.debtTransactions.getSync(id);
    tx?.person.loadSync();
    return tx;
  }

  yield load();

  await for (final _ in db.debtTransactions.watchObjectLazy(id)) {
    yield load();
  }
}

@riverpod
Stream<List<Payment>> paymentsForTransaction(Ref ref, int transactionId) async* {
  final db = ref.watch(isarProvider);

  List<Payment> load() {
    return db.payments
        .filter()
        .transaction((q) => q.idEqualTo(transactionId))
        .sortByDateDesc()
        .findAllSync();
  }

  yield load();

  await for (final _ in db.payments.watchLazy()) {
    yield load();
  }
}

@riverpod
Stream<List<DebtTransaction>> transactionsForPerson(Ref ref, int personId) async* {
  final db = ref.watch(isarProvider);

  List<DebtTransaction> load() {
    final all = db.debtTransactions.where().findAllSync();
    final filtered = <DebtTransaction>[];
    for (final tx in all) {
      tx.person.loadSync();
      if (tx.person.value?.id == personId) {
        filtered.add(tx);
      }
    }
    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  yield load();

  await for (final _ in db.debtTransactions.watchLazy()) {
    yield load();
  }
}

@riverpod
Future<Person?> personById(Ref ref, int id) async {
  final db = ref.watch(isarProvider);
  return db.persons.get(id);
}

@riverpod
Future<void> markAsSettled(Ref ref, int transactionId) async {
  final db = ref.watch(isarProvider);
  final tx = await db.debtTransactions.get(transactionId);
  if (tx == null) return;

  await db.writeTxn(() async {
    tx.status = TransactionStatus.settled;
    tx.amountPaid = tx.amount;
    await db.debtTransactions.put(tx);
  });
}

@riverpod
Future<void> deleteTransaction(Ref ref, int transactionId) async {
  final db = ref.watch(isarProvider);

  // Delete associated payments first
  final payments = await db.payments
      .filter()
      .transaction((q) => q.idEqualTo(transactionId))
      .findAll();

  await db.writeTxn(() async {
    for (final p in payments) {
      await db.payments.delete(p.id);
    }
    await db.debtTransactions.delete(transactionId);
  });
}
