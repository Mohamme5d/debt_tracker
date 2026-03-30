import '../core/database/database_helper.dart';
import '../models/monthly_deposit.dart';

class MonthlyDepositRepository {
  final _db = DatabaseHelper();

  Future<List<MonthlyDeposit>> getAll() async {
    final db = await _db.database;
    final maps = await db.query('monthly_deposits',
        orderBy: 'deposit_year DESC, deposit_month DESC');
    return maps.map(MonthlyDeposit.fromMap).toList();
  }

  Future<MonthlyDeposit?> getByMonthYear(int month, int year) async {
    final db = await _db.database;
    final maps = await db.query('monthly_deposits',
        where: 'deposit_month = ? AND deposit_year = ?',
        whereArgs: [month, year]);
    if (maps.isEmpty) return null;
    return MonthlyDeposit.fromMap(maps.first);
  }

  Future<int> insert(MonthlyDeposit deposit) async {
    final db = await _db.database;
    return db.insert('monthly_deposits', deposit.toMap());
  }

  Future<int> update(MonthlyDeposit deposit) async {
    final db = await _db.database;
    return db.update('monthly_deposits', deposit.toMap(),
        where: 'id = ?', whereArgs: [deposit.id]);
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return db.delete('monthly_deposits', where: 'id = ?', whereArgs: [id]);
  }
}
