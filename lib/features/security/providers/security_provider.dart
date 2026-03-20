import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'security_provider.g.dart';

class SecurityState {
  final bool isLocked;
  final bool isBiometricEnabled;
  final bool isPasscodeEnabled;
  final int autoLockSeconds; // 0=immediate, 60=1min, 300=5min

  const SecurityState({
    this.isLocked = false,
    this.isBiometricEnabled = false,
    this.isPasscodeEnabled = false,
    this.autoLockSeconds = 0,
  });

  SecurityState copyWith({
    bool? isLocked,
    bool? isBiometricEnabled,
    bool? isPasscodeEnabled,
    int? autoLockSeconds,
  }) {
    return SecurityState(
      isLocked: isLocked ?? this.isLocked,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isPasscodeEnabled: isPasscodeEnabled ?? this.isPasscodeEnabled,
      autoLockSeconds: autoLockSeconds ?? this.autoLockSeconds,
    );
  }

  bool get hasAnySecurity => isBiometricEnabled || isPasscodeEnabled;
}

@Riverpod(keepAlive: true)
class SecurityNotifier extends _$SecurityNotifier {
  static const _biometricKey = 'biometric_enabled';
  static const _passcodeKey = 'passcode_enabled';
  static const _autoLockKey = 'auto_lock_seconds';
  static const _passcodeStorageKey = 'app_passcode';

  final _auth = LocalAuthentication();
  final _secureStorage = const FlutterSecureStorage();

  @override
  SecurityState build() {
    _loadSettings();
    return const SecurityState();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final biometric = prefs.getBool(_biometricKey) ?? false;
    final passcode = prefs.getBool(_passcodeKey) ?? false;
    final autoLock = prefs.getInt(_autoLockKey) ?? 0;

    state = state.copyWith(
      isBiometricEnabled: biometric,
      isPasscodeEnabled: passcode,
      autoLockSeconds: autoLock,
      isLocked: biometric || passcode,
    );
  }

  void lock() {
    if (state.hasAnySecurity) {
      state = state.copyWith(isLocked: true);
    }
  }

  void unlock() {
    state = state.copyWith(isLocked: false);
  }

  Future<bool> checkBiometric() async {
    try {
      final isDeviceSupported = await _auth.isDeviceSupported();
      if (!isDeviceSupported) return false;

      final didAuth = await _auth.authenticate(
        localizedReason: 'Authenticate to access Raseed',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // allow device passcode as fallback
        ),
      );

      if (didAuth) {
        unlock();
      }
      return didAuth;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> isBiometricAvailable() async {
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  Future<void> toggleBiometric(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricKey, enabled);
    state = state.copyWith(isBiometricEnabled: enabled);
  }

  Future<void> setPasscode(String pin) async {
    await _secureStorage.write(key: _passcodeStorageKey, value: pin);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_passcodeKey, true);
    state = state.copyWith(isPasscodeEnabled: true);
  }

  Future<void> removePasscode() async {
    await _secureStorage.delete(key: _passcodeStorageKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_passcodeKey, false);
    state = state.copyWith(isPasscodeEnabled: false);
  }

  Future<bool> verifyPasscode(String pin) async {
    final stored = await _secureStorage.read(key: _passcodeStorageKey);
    final match = stored == pin;
    if (match) {
      unlock();
    }
    return match;
  }

  Future<void> setAutoLock(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_autoLockKey, seconds);
    state = state.copyWith(autoLockSeconds: seconds);
  }
}
