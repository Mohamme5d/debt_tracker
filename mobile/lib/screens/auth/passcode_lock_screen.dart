import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/security_service.dart';

class PasscodeLockScreen extends StatefulWidget {
  /// If true, shown at app launch; if false, navigating back is allowed (settings).
  final bool isAppLock;
  const PasscodeLockScreen({super.key, this.isAppLock = true});

  @override
  State<PasscodeLockScreen> createState() => _PasscodeLockScreenState();
}

class _PasscodeLockScreenState extends State<PasscodeLockScreen> {
  final _security = SecurityService();
  final _controller = TextEditingController();
  bool _error = false;
  bool _biometricsAvailable = false;
  bool _biometricsEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final available = await _security.isBiometricsAvailable();
    final enabled = await _security.isBiometricsEnabled();
    if (mounted) {
      setState(() {
        _biometricsAvailable = available;
        _biometricsEnabled = enabled;
      });
      if (available && enabled) {
        Future.delayed(const Duration(milliseconds: 300), _tryBiometrics);
      }
    }
  }

  Future<void> _tryBiometrics() async {
    final ok = await _security.authenticateWithBiometrics();
    if (ok && mounted) _unlock();
  }

  void _unlock() {
    context.go('/dashboard');
  }

  Future<void> _verify(String pin) async {
    final ok = await _security.verifyPasscode(pin);
    if (ok) {
      _unlock();
    } else {
      setState(() => _error = true);
      _controller.clear();
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.white)),
        content: const Text(
          'هل تريد تسجيل الخروج؟ سيتم حذف رمز القفل.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('خروج', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await _security.clearPasscode();
      await context.read<AuthProvider>().logout();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(),
              // Lock icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.lock_rounded, color: AppColors.primary, size: 40),
              ),
              const SizedBox(height: 24),
              const Text(
                'إيجاري',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error ? 'رمز خاطئ، حاول مجدداً' : 'أدخل رمز القفل',
                style: TextStyle(
                  color: _error ? AppColors.danger : AppColors.textSecondary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 36),
              Pinput(
                controller: _controller,
                length: 4,
                obscureText: true,
                autofocus: true,
                defaultPinTheme: defaultTheme,
                focusedPinTheme: defaultTheme.copyWith(
                  decoration: defaultTheme.decoration!.copyWith(
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                ),
                errorPinTheme: defaultTheme.copyWith(
                  decoration: defaultTheme.decoration!.copyWith(
                    border: Border.all(color: AppColors.danger, width: 2),
                  ),
                ),
                onCompleted: _verify,
              ),
              const SizedBox(height: 32),
              if (_biometricsAvailable && _biometricsEnabled)
                TextButton.icon(
                  onPressed: _tryBiometrics,
                  icon: const Icon(Icons.fingerprint_rounded, size: 28),
                  label: const Text('استخدم البصمة'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              const Spacer(),
              TextButton(
                onPressed: _logout,
                child: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
