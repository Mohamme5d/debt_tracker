import 'package:flutter/material.dart';
import '../models/apartment.dart';
import '../services/api/apartment_api_service.dart';

class ApartmentProvider extends ChangeNotifier {
  final _api = ApartmentApiService();
  List<Apartment> _apartments = [];
  bool _loading = false;
  String? _error;

  List<Apartment> get apartments => _apartments;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _apartments = await _api.getAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> add(Apartment apartment) async {
    try {
      await _api.create(apartment);
      await load();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> edit(Apartment apartment) async {
    try {
      await _api.update(apartment.id!, apartment);
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
