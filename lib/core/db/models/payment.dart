import 'package:isar/isar.dart';

import 'debt_transaction.dart';

part 'payment.g.dart';

@collection
class Payment {
  Id id = Isar.autoIncrement;

  final transaction = IsarLink<DebtTransaction>();

  double amount = 0;

  DateTime date = DateTime.now();

  String? note;
}
