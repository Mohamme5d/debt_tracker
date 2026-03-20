import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:raseed/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/widgets/raseed_logo.dart';
import '../../../core/widgets/raseed_wordmark.dart';
import '../providers/security_provider.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  bool _showPasscode = false;
  String _entered = '';
  bool _isError = false;
  bool _biometricTriggered = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _tryBiometric() async {
    // Wait for the activity to be fully resumed before showing biometric prompt
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    final security = ref.read(securityNotifierProvider);
    if (!security.isBiometricEnabled) return;
    // Only trigger if app is still in the foreground
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      await ref.read(securityNotifierProvider.notifier).checkBiometric();
    }
  }

  void _onDigit(int digit) {
    if (_entered.length >= 6) return;
    setState(() {
      _entered += digit.toString();
      _isError = false;
    });
    if (_entered.length == 6) {
      _verifyPasscode();
    }
  }

  void _onDelete() {
    if (_entered.isNotEmpty) {
      setState(() => _entered = _entered.substring(0, _entered.length - 1));
    }
  }

  Future<void> _verifyPasscode() async {
    final ok =
        await ref.read(securityNotifierProvider.notifier).verifyPasscode(_entered);
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _isError = true;
        _entered = '';
      });
    }
    // If ok, securityNotifier.unlock() was called → overlay disappears automatically
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final security = ref.watch(securityNotifierProvider);

    // Trigger biometric once the security state is loaded (isBiometricEnabled
    // transitions from false→true when SharedPreferences finishes loading).
    if (security.isBiometricEnabled && !_biometricTriggered) {
      _biometricTriggered = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometric());
    }

    return DefaultTextStyle(
      style: const TextStyle(
        decoration: TextDecoration.none,
        decorationColor: Colors.transparent,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Material(
          color: AppTheme.backgroundDark.withOpacity(0.97),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: _showPasscode
                  ? _buildPasscodeView(l10n, security)
                  : _buildMainView(l10n, security),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainView(AppLocalizations l10n, SecurityState security) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _scaleAnim,
            child: const RaseedLogo(size: 96),
          ),
          const SizedBox(height: 20),
          const RaseedWordmark(size: 28),
          const SizedBox(height: 8),
          Text(
            l10n.unlockApp,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            Localizations.localeOf(context).languageCode == 'ar'
                ? 'بياناتك المالية في أمان'
                : 'Your financial data, secured',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.4),
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 48),
          if (security.isBiometricEnabled)
            GestureDetector(
              onTap: _tryBiometric,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.fingerprint_rounded,
                        color: AppTheme.primaryColor, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      l10n.useBiometric,
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (security.isBiometricEnabled && security.isPasscodeEnabled)
            const SizedBox(height: 16),
          if (security.isPasscodeEnabled)
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white.withOpacity(0.7),
              ),
              onPressed: () => setState(() {
                _showPasscode = true;
                _entered = '';
                _isError = false;
              }),
              child: Text(
                l10n.enterPasscode,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPasscodeView(AppLocalizations l10n, SecurityState security) {
    return Column(
      children: [
        Align(
          alignment: AlignmentDirectional.topStart,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => setState(() {
              _showPasscode = false;
              _entered = '';
              _isError = false;
            }),
          ),
        ),
        const Spacer(),
        const RaseedLogo(size: 64),
        const SizedBox(height: 20),
        Text(
          _isError ? l10n.wrongPasscode : l10n.enterPasscode,
          style: TextStyle(
            color: _isError ? AppTheme.debtColor : Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 40),
        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (i) {
            final filled = i < _entered.length;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isError
                    ? AppTheme.debtColor
                    : filled
                        ? AppTheme.primaryColor
                        : Colors.transparent,
                border: Border.all(
                  color:
                      _isError ? AppTheme.debtColor : AppTheme.primaryColor,
                  width: 2,
                ),
              ),
            );
          }),
        ),
        const Spacer(),
        _buildNumpad(security),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildNumpad(SecurityState security) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          children: [
            for (int row = 0; row < 4; row++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _buildRow(row, security),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRow(int row, SecurityState security) {
    if (row < 3) {
      return List.generate(3, (col) {
        final digit = row * 3 + col + 1;
        return _NumpadButton(
          label: digit.toString(),
          onTap: () => _onDigit(digit),
        );
      });
    }
    return [
      if (security.isBiometricEnabled)
        _NumpadButton(
          icon: Icons.fingerprint_rounded,
          onTap: _tryBiometric,
        )
      else
        const SizedBox(width: 72, height: 72),
      _NumpadButton(label: '0', onTap: () => _onDigit(0)),
      _NumpadButton(icon: Icons.backspace_rounded, onTap: _onDelete),
    ];
  }
}

class _NumpadButton extends StatelessWidget {
  const _NumpadButton({this.label, this.icon, required this.onTap});

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.surfaceDark.withOpacity(0.5),
          border: Border.all(color: AppTheme.borderDark.withOpacity(0.3)),
        ),
        child: Center(
          child: label != null
              ? Text(
                  label!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : Icon(icon, color: Colors.white.withOpacity(0.7), size: 24),
        ),
      ),
    );
  }
}
