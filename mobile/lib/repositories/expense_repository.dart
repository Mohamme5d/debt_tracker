import '../core/database/database_helper.dart';
import '../models/expense.dart';

class ExpenseRepository {
  final _db = DatabaseHelper();

  Future<List<Expense>> getAll() async {
    final db = await _db.database;
    final maps = await db.query('expenses', orderBy: 'expense_date DESC');
    return maps.map(Expense.fromMap).toList();
  }

  Future<List<Expense>> getByMonthYear(int month, int year) async {
    final db = await _db.database;
    final maps = await db.query('expenses',
        where: 'month = ? AND year = ?',
        whereArgs: [month, year],
        orderBy: 'expense_date DESC');
    return maps.map(Expense.fromMap).toList();
  }

  Future<double> getTotalByMonthYear(int month, int year) async {
    final db = await _db.database;
    final maps = await db.rawQuery(
        'SELECT SUM(amount) AS total FROM expenses WHERE month = ? AND year = ?',
        [month, year]);
    return (maps.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<int> insert(Expense expense) async {
    final db = await _db.database;
    return db.insert('expenses', expense.toMap());
  }

  Future<int> update(Expense expense) async {
    final db = await _db.database;
    return db.update('expenses', expense.toMap(),
        where: 'id = ?', whereArgs: [expense.id]);
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }
}
