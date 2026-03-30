import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages passcode and biometric authentication for app lock.
class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  final _localAuth = LocalAuthentication();

  static const _passcodeKey = 'passcode_hash';
  static const _biometricsKey = 'biometrics_enabled';

  // ─── Passcode ────────────────────────────────────────────────────────────────

  Future<bool> hasPasscode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_passcodeKey);
  }

  Future<void> setPasscode(String pin) async {
    final hash = _hashPin(pin);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passcodeKey, hash);
  }

  Future<bool> verifyPasscode(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_passcodeKey);
    if (stored == null) return false;
    return stored == _hashPin(pin);
  }

  Future<void> clearPasscode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_passcodeKey);
    await prefs.remove(_biometricsKey);
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  // ─── Biometrics ──────────────────────────────────────────────────────────────

  Future<bool> isBiometricsAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } on PlatformException {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  Future<bool> isBiometricsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricsKey) ?? false;
  }

  Future<void> setBiometricsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricsKey, enabled);
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Ijari',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } on PlatformException {
      return false;
    }
  }

  // ─── Unified lock check ──────────────────────────────────────────────────────

  /// Returns true if the app should show the lock screen on resume.
  Future<bool> isLockEnabled() async {
    return await hasPasscode();
  }
}
