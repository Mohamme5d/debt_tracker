import 'package:isar/isar.dart';

import '../../../core/db/models/debt_transaction.dart';
import '../../../core/db/models/enums.dart';
import '../../../core/db/models/payment.dart';

class RecordPaymentUseCase {
  final Isar _isar;

  RecordPaymentUseCase(this._isar);

  Future<Payment> execute({
    required DebtTransaction transaction,
    required double amount,
    String? note,
    DateTime? date,
    List<String>? attachmentPaths,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Payment amount must be greater than zero');
    }
    if (amount > transaction.remaining) {
      throw ArgumentError(
        'Payment amount cannot exceed remaining balance of '
        '${transaction.remaining.toStringAsFixed(2)}',
      );
    }

    final payment = Payment()
      ..amount = amount
      ..date = date ?? DateTime.now()
      ..note = note
      ..attachmentPaths = attachmentPaths ?? [];

    await _isar.writeTxn(() async {
      await _isar.payments.put(payment);
      payment.transaction.value = transaction;
      await payment.transaction.save();

      transaction.amountPaid += amount;
      if (transaction.remaining <= 0) {
        transaction.status = TransactionStatus.settled;
      }
      await _isar.debtTransactions.put(transaction);
    });

    return payment;
  }

  Future<void> deletePayment({
    required Payment payment,
    required DebtTransaction transaction,
  }) async {
    await _isar.writeTxn(() async {
      transaction.amountPaid -= payment.amount;
      if (transaction.amountPaid < 0) transaction.amountPaid = 0;

      if (transaction.status == TransactionStatus.settled) {
        transaction.status = TransactionStatus.active;
      }

      await _isar.debtTransactions.put(transaction);
      await _isar.payments.delete(payment.id);
    });
  }
}
