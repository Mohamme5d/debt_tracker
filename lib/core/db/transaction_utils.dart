import 'package:isar/isar.dart';

import 'models/debt_transaction.dart';
import 'models/enums.dart';

/// Checks every unsettled transaction against today's date and flips the
/// status to [TransactionStatus.overdue] when the due date has passed.
/// Returns true if any records were updated (callers can use this to decide
/// whether to re-emit a stream event).
Future<bool> syncOverdueStatus(Isar db) async {
  final now = DateTime.now();

  final candidates = await db.debtTransactions
      .filter()
      .statusEqualTo(TransactionStatus.active)
      .findAll();

  final overdue = candidates
      .where((tx) => tx.dueDate != null && tx.dueDate!.isBefore(now))
      .toList();

  if (overdue.isEmpty) return false;

  await db.writeTxn(() async {
    for (final tx in overdue) {
      tx.status = TransactionStatus.overdue;
    }
    await db.debtTransactions.putAll(overdue);
  });

  return true;
}
