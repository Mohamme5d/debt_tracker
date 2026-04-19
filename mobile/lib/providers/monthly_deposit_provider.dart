import 'package:flutter/material.dart';
import '../models/monthly_deposit.dart';
import '../services/api/deposit_api_service.dart';

class MonthlyDepositProvider extends ChangeNotifier {
  final _api = DepositApiService();
  List<MonthlyDeposit> _deposits = [];
  bool _loading = false;
  String? _error;

  List<MonthlyDeposit> get deposits => _deposits;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final list = await _api.getAll();
      list.sort((a, b) {
        final cmp = b.depositYear.compareTo(a.depositYear);
        return cmp != 0 ? cmp : b.depositMonth.compareTo(a.depositMonth);
      });
      _deposits = list;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  MonthlyDeposit? getByMonthYear(int month, int year) {
    try {
      return _deposits.firstWhere(
          (d) => d.depositMonth == month && d.depositYear == year);
    } catch (_) {
      return null;
    }
  }

  Future<String> add(MonthlyDeposit deposit) async {
    try {
      await _api.create(deposit);
      await load();
      return 'ok';
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('409') || msg.contains('Conflict')) return 'duplicate';
      _error = msg;
      notifyListeners();
      return msg;
    }
  }

  Future<bool> edit(MonthlyDeposit deposit) async {
    try {
      await _api.update(deposit.id!, deposit);
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
