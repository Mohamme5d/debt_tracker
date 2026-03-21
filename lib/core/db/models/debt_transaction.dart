import 'package:isar/isar.dart';

import 'enums.dart';
import 'person.dart';

part 'debt_transaction.g.dart';

@collection
class DebtTransaction {
  Id id = Isar.autoIncrement;

  final person = IsarLink<Person>();

  @enumerated
  TransactionType type = TransactionType.debt;

  double amount = 0;

  double amountPaid = 0;

  DateTime date = DateTime.now();

  DateTime? dueDate;

  String? note;

  List<String> attachmentPaths = [];

  @enumerated
  TransactionStatus status = TransactionStatus.active;

  double get remaining => amount - amountPaid;

  bool get isSettled => remaining <= 0;
}
