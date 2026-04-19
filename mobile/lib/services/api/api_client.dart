import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../core/router/app_router.dart';

void _log(String msg) => debugPrint('[ApiClient] $msg');

class ApiClient {
  static const String _baseUrl = 'https://ijari-api.nexiscore.com/api';
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;
  final _storage = const FlutterSecureStorage();

  static const _accessTokenKey  = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _emailKey        = 'saved_email';
  static const _passwordKey     = 'saved_password';

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(PrettyDioLogger(
      requestHeader: false,
      requestBody: true,
      responseBody: true,
      error: true,
      compact: true,
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: _accessTokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        _log('onError: type=${error.type} status=${error.response?.statusCode}');
        if (error.response?.statusCode == 401) {
          final recovered = await _tryRefresh() || await _tryReLogin();
          if (recovered) {
            final token = await _storage.read(key: _accessTokenKey);
            error.requestOptions.headers['Authorization'] = 'Bearer $token';
            final resp = await dio.fetch(error.requestOptions);
            return handler.resolve(resp);
          }
          // All recovery attempts failed — go to login
          await clearTokens();
          AppRouter.router.go('/login');
        }
        handler.next(error);
      },
    ));
  }

  /// Try refreshing with the stored refresh token.
  Future<bool> _tryRefresh() async {
    try {
      final rt = await _storage.read(key: _refreshTokenKey);
      if (rt == null) return false;
      final resp = await Dio(BaseOptions(baseUrl: _baseUrl))
          .post('/auth/refresh', data: {'refreshToken': rt});
      await saveTokens(resp.data['accessToken'], resp.data['refreshToken']);
      _log('Token refreshed successfully');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Try re-logging in with saved credentials.
  Future<bool> _tryReLogin() async {
    try {
      final email    = await _storage.read(key: _emailKey);
      final password = await _storage.read(key: _passwordKey);
      if (email == null || password == null) return false;
      _log('Re-logging in as $email');
      final resp = await Dio(BaseOptions(baseUrl: _baseUrl))
          .post('/auth/login', data: {'email': email, 'password': password});
      await saveTokens(resp.data['accessToken'], resp.data['refreshToken']);
      _log('Re-login successful');
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> saveCredentials(String email, String password) async {
    await _storage.write(key: _emailKey, value: email);
    await _storage.write(key: _passwordKey, value: password);
  }

  Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: _accessTokenKey, value: access);
    await _storage.write(key: _refreshTokenKey, value: refresh);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);
}
