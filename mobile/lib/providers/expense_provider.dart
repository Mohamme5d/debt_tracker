import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/api/expense_api_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final _api = ExpenseApiService();
  List<Expense> _expenses = [];
  bool _loading = false;
  String? _error;

  List<Expense> get expenses => _expenses;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load({int? month, int? year}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _expenses = _sorted(await _api.getAll(month: month, year: year));
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<List<Expense>> getByMonthYear(int month, int year) async =>
      _sorted(await _api.getAll(month: month, year: year));

  Future<double> getTotalByMonthYear(int month, int year) async {
    final list = await _api.getAll();
    return list
        .where((e) => e.month == month && e.year == year)
        .fold<double>(0.0, (sum, e) => sum + e.amount);
  }

  /// Fetches all expenses once and returns a map of 'year-month' → total amount.
  /// Used by Excel export to avoid one API call per month.
  Future<Map<String, double>> fetchAllExpenseTotals() async {
    final list = await _api.getAll();
    final map = <String, double>{};
    for (final e in list) {
      final key = '${e.year}-${e.month}';
      map[key] = (map[key] ?? 0.0) + e.amount;
    }
    return map;
  }

  Future<bool> add(Expense expense) async {
    try {
      await _api.create(expense);
      await load();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> edit(Expense expense) async {
    try {
      await _api.update(expense.id!, expense);
      await load();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  static List<Expense> _sorted(List<Expense> list) {
    list.sort((a, b) => b.expenseDate.compareTo(a.expenseDate));
    return list;
  }

  Future<bool> remove(String id) async {
    try {
      await _api.delete(id);
      await load();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
