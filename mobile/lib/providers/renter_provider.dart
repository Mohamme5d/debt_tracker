import 'package:flutter/material.dart';
import '../models/renter.dart';
import '../services/api/renter_api_service.dart';

class RenterProvider extends ChangeNotifier {
  final _api = RenterApiService();
  List<Renter> _renters = [];
  bool _loading = false;
  String? _error;

  List<Renter> get renters => _renters;
  List<Renter> get activeRenters => _renters.where((r) => r.status == 'Approved').toList();
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _renters = await _api.getAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> add(Renter renter) async {
    try {
      await _api.create(renter);
      await load();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> edit(Renter renter) async {
    try {
      await _api.update(renter.id!, renter);
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
