import 'package:isar/isar.dart';

import '../../../core/db/models/debt_transaction.dart';
import '../../../core/db/models/enums.dart';
import '../../../core/db/models/person.dart';

class EditTransactionUseCase {
  final Isar _isar;

  EditTransactionUseCase(this._isar);

  Future<void> execute({
    required DebtTransaction transaction,
    required Person person,
    required TransactionType type,
    required double amount,
    required DateTime date,
    DateTime? dueDate,
    String? note,
    List<String>? attachmentPaths,
  }) async {
    if (amount <= 0) throw ArgumentError('Amount must be greater than zero');
    if (amount < transaction.amountPaid) {
      throw ArgumentError(
          'Amount cannot be less than amount already paid (${transaction.amountPaid})');
    }

    await _isar.writeTxn(() async {
      if (person.id == Isar.autoIncrement) {
        await _isar.persons.put(person);
      }

      transaction
        ..type = type
        ..amount = amount
        ..date = date
        ..dueDate = dueDate
        ..note = note
        ..attachmentPaths = attachmentPaths ?? transaction.attachmentPaths;

      // Re-evaluate status
      if (transaction.remaining <= 0) {
        transaction.status = TransactionStatus.settled;
      } else if (transaction.status == TransactionStatus.settled) {
        transaction.status = TransactionStatus.active;
      }

      await _isar.debtTransactions.put(transaction);
      transaction.person.value = person;
      await transaction.person.save();
    });
  }
}
