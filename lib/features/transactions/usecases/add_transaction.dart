import 'package:isar/isar.dart';

import '../../../core/db/models/debt_transaction.dart';
import '../../../core/db/models/enums.dart';
import '../../../core/db/models/person.dart';
import '../../../core/services/notification_service.dart';

class AddTransactionUseCase {
  final Isar _isar;

  AddTransactionUseCase(this._isar);

  Future<DebtTransaction> execute({
    required Person person,
    required TransactionType type,
    required double amount,
    required DateTime date,
    DateTime? dueDate,
    String? note,
    List<String>? attachmentPaths,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Amount must be greater than zero');
    }

    final tx = DebtTransaction()
      ..type = type
      ..amount = amount
      ..amountPaid = 0
      ..date = date
      ..dueDate = dueDate
      ..note = note
      ..attachmentPaths = attachmentPaths ?? []
      ..status = TransactionStatus.active;

    await _isar.writeTxn(() async {
      // Ensure person is saved
      if (person.id == Isar.autoIncrement) {
        await _isar.persons.put(person);
      }
      await _isar.debtTransactions.put(tx);
      tx.person.value = person;
      await tx.person.save();
    });

    try {
      await NotificationService.scheduleTransactionDue(tx);
    } catch (_) {}


    return tx;
  }
}
