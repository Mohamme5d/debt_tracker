import 'package:flutter/material.dart';
import '../services/api/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _auth = AuthService();

  Map<String, dynamic>? _user;
  bool _loading = true;

  Map<String, dynamic>? get user => _user;
  bool get loading => _loading;
  bool get isLoggedIn => _user != null;
  String? get role => _user?['role'] as String?;
  bool get isOwner => role == 'Owner';
  String get displayName => (_user?['name'] as String?) ?? '';
  String get displayEmail => (_user?['email'] as String?) ?? '';

  Future<void> initialize() async {
    _loading = true;
    notifyListeners();
    final loggedIn = await _auth.isLoggedIn();
    if (loggedIn) {
      _user = await _auth.getCurrentUser();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _user = await _auth.login(email, password);
    notifyListeners();
  }

  Future<void> register({
    required String tenantName,
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    _user = await _auth.register(
      tenantName: tenantName,
      name: name,
      email: email,
      password: password,
      phone: phone,
    );
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.logout();
    _user = null;
    notifyListeners();
  }
}
