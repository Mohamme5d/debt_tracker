import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'models/debt_transaction.dart';
import 'models/payment.dart';
import 'models/person.dart';

part 'isar_service.g.dart';

class IsarService {
  late Isar _isar;

  Isar get isar => _isar;

  static IsarService? _instance;

  IsarService._();

  static Future<IsarService> init() async {
    if (_instance != null) return _instance!;

    _instance = IsarService._();
    final dir = await getApplicationDocumentsDirectory();
    _instance!._isar = await Isar.open(
      [PersonSchema, DebtTransactionSchema, PaymentSchema],
      directory: dir.path,
    );
    return _instance!;
  }
}

@Riverpod(keepAlive: true)
IsarService isarService(Ref ref) {
  throw UnimplementedError('isarService must be overridden at startup');
}

@Riverpod(keepAlive: true)
Isar isar(Ref ref) {
  return ref.watch(isarServiceProvider).isar;
}
