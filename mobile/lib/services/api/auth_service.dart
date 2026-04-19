import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'api_client.dart';

class AuthService {
  final _client = ApiClient();

  static const _userKey = 'current_user';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final resp = await _client.dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    await _saveSession(resp.data);
    await _client.saveCredentials(email, password);
    return resp.data['user'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register({
    required String tenantName,
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final resp = await _client.dio.post('/auth/register', data: {
      'tenantName': tenantName,
      'name': name,
      'email': email,
      'password': password,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    });
    await _saveSession(resp.data);
    return resp.data['user'] as Map<String, dynamic>;
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rt = prefs.getString('refreshToken');
      if (rt != null) {
        await _client.dio.post('/auth/logout', data: {'refreshToken': rt});
      }
    } catch (_) {}
    await _client.clearTokens();
    await _client.saveCredentials('', ''); // wipe saved credentials
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove('passcode_hash');
    await prefs.remove('biometrics_enabled');
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    return json.decode(userJson) as Map<String, dynamic>;
  }

  Future<bool> isLoggedIn() async {
    final token = await _client.getAccessToken();
    return token != null;
  }

  String? get currentRole {
    // Synchronous fallback — reads from SharedPreferences during session
    return null;
  }

  Future<String?> getCurrentRole() async {
    final user = await getCurrentUser();
    return user?['role'] as String?;
  }

  Future<void> _saveSession(Map<String, dynamic> data) async {
    await _client.saveTokens(data['accessToken'], data['refreshToken']);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(data['user']));
    // Store refreshToken separately for logout
    await prefs.setString('refreshToken', data['refreshToken']);
  }
}
