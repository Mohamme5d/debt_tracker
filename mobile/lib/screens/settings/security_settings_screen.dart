import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../../core/theme/app_colors.dart';
import '../../services/security_service.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final _security = SecurityService();

  bool _hasPasscode = false;
  bool _biometricsAvailable = false;
  bool _biometricsEnabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final has = await _security.hasPasscode();
    final available = await _security.isBiometricsAvailable();
    final enabled = await _security.isBiometricsEnabled();
    if (mounted) {
      setState(() {
        _hasPasscode = has;
        _biometricsAvailable = available;
        _biometricsEnabled = enabled;
        _loading = false;
      });
    }
  }

  // ── Passcode setup dialog ─────────────────────────────────────────────────

  Future<String?> _showPinDialog({
    required String title,
    required String hint,
  }) async {
    String? result;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(hint,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 20),
              Pinput(
                controller: controller,
                length: 4,
                obscureText: true,
                autofocus: true,
                defaultPinTheme: PinTheme(
                  width: 52,
                  height: 52,
                  textStyle: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                ),
                focusedPinTheme: PinTheme(
                  width: 52,
                  height: 52,
                  textStyle: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                ),
                onCompleted: (pin) {
                  result = pin;
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
          ],
        );
      },
    );
    return result;
  }

  // ── Toggle passcode ───────────────────────────────────────────────────────

  Future<void> _togglePasscode(bool value) async {
    if (value) {
      // Enable: ask for new PIN twice
      final pin1 = await _showPinDialog(
        title: 'رمز قفل جديد',
        hint: 'أدخل رمزاً مكوناً من 4 أرقام',
      );
      if (pin1 == null) return;

      final pin2 = await _showPinDialog(
        title: 'تأكيد الرمز',
        hint: 'أعد إدخال الرمز للتأكيد',
      );
      if (pin2 == null) return;

      if (pin1 != pin2) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('الرمزان غير متطابقين')),
          );
        }
        return;
      }

      await _security.setPasscode(pin1);
      if (mounted) setState(() => _hasPasscode = true);
    } else {
      // Disable: verify current PIN first
      final pin = await _showPinDialog(
        title: 'تعطيل القفل',
        hint: 'أدخل رمزك الحالي لتأكيد التعطيل',
      );
      if (pin == null) return;

      final ok = await _security.verifyPasscode(pin);
      if (!ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('رمز خاطئ')),
          );
        }
        return;
      }

      await _security.clearPasscode();
      if (mounted) setState(() {
        _hasPasscode = false;
        _biometricsEnabled = false;
      });
    }
  }

  // ── Toggle biometrics ─────────────────────────────────────────────────────

  Future<void> _toggleBiometrics(bool value) async {
    await _security.setBiometricsEnabled(value);
    if (mounted) setState(() => _biometricsEnabled = value);
  }

  // ── Change PIN ────────────────────────────────────────────────────────────

  Future<void> _changePin() async {
    final current = await _showPinDialog(
      title: 'الرمز الحالي',
      hint: 'أدخل رمزك الحالي',
    );
    if (current == null) return;

    final ok = await _security.verifyPasscode(current);
    if (!ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('رمز خاطئ')),
        );
      }
      return;
    }

    final pin1 = await _showPinDialog(
      title: 'رمز جديد',
      hint: 'أدخل رمزاً جديداً مكوناً من 4 أرقام',
    );
    if (pin1 == null) return;

    final pin2 = await _showPinDialog(
      title: 'تأكيد الرمز الجديد',
      hint: 'أعد إدخال الرمز الجديد',
    );
    if (pin2 == null) return;

    if (pin1 != pin2) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرمزان غير متطابقين')),
        );
      }
      return;
    }

    await _security.setPasscode(pin1);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تغيير الرمز بنجاح')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text('الأمان والخصوصية'),
        backgroundColor: AppColors.surface,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionCard(
                  title: 'قفل التطبيق',
                  children: [
                    SwitchListTile(
                      value: _hasPasscode,
                      onChanged: _togglePasscode,
                      title: const Text('رمز القفل',
                          style: TextStyle(color: Colors.white)),
                      subtitle: const Text('قفل التطبيق برمز سري مكون من 4 أرقام',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      secondary: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.lock_outline_rounded,
                            color: AppColors.primary),
                      ),
                      activeColor: AppColors.primary,
                    ),
                    if (_hasPasscode) ...[
                      const Divider(color: AppColors.border, height: 1),
                      ListTile(
                        onTap: _changePin,
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.edit_rounded,
                              color: AppColors.accent),
                        ),
                        title: const Text('تغيير الرمز',
                            style: TextStyle(color: Colors.white)),
                        trailing: const Icon(Icons.chevron_right_rounded,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                if (_biometricsAvailable)
                  _SectionCard(
                    title: 'البصمة / Face ID',
                    children: [
                      SwitchListTile(
                        value: _biometricsEnabled,
                        onChanged: _hasPasscode ? _toggleBiometrics : null,
                        title: const Text('تسجيل الدخول بالبصمة',
                            style: TextStyle(color: Colors.white)),
                        subtitle: Text(
                          _hasPasscode
                              ? 'فتح التطبيق بالبصمة بدلاً من الرمز'
                              : 'يجب تفعيل رمز القفل أولاً',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12),
                        ),
                        secondary: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.fingerprint_rounded,
                              color: AppColors.success),
                        ),
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
              ],
            ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}
