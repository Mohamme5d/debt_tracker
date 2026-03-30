import 'package:flutter/material.dart';
import '../models/rent_contract.dart';
import '../services/api/rent_contract_api_service.dart';

class RentContractProvider extends ChangeNotifier {
  final _api = RentContractApiService();
  List<RentContract> _contracts = [];
  bool _loading = false;
  String? _error;

  List<RentContract> get contracts => _contracts;
  List<RentContract> get activeContracts =>
      _contracts.where((c) => c.isActive).toList();
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _contracts = await _api.getAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> add(RentContract contract) async {
    try {
      await _api.create(contract);
      await load();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> edit(RentContract contract) async {
    try {
      await _api.update(contract.id!, contract);
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
