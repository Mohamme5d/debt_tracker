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
      _expenses = await _api.getAll(month: month, year: year);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<List<Expense>> getByMonthYear(int month, int year) =>
      _api.getAll(month: month, year: year);

  Future<double> getTotalByMonthYear(int month, int year) async {
    final list = await _api.getAll(month: month, year: year);
    return list.fold<double>(0.0, (sum, e) => sum + e.amount);
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
