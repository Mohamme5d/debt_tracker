import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:raseed/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../providers/security_provider.dart';

enum PasscodeMode { verify, set, confirm }

class PasscodeScreen extends ConsumerStatefulWidget {
  const PasscodeScreen({
    super.key,
    required this.mode,
    this.firstPasscode,
    this.onSuccess,
  });

  final PasscodeMode mode;
  final String? firstPasscode;
  final VoidCallback? onSuccess;

  @override
  ConsumerState<PasscodeScreen> createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends ConsumerState<PasscodeScreen>
    with SingleTickerProviderStateMixin {
  String _entered = '';
  bool _isError = false;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 24).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reset();
        setState(() {
          _entered = '';
          _isError = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  String get _title {
    final l10n = AppLocalizations.of(context)!;
    switch (widget.mode) {
      case PasscodeMode.verify:
        return _isError ? l10n.wrongPasscode : l10n.enterPasscode;
      case PasscodeMode.set:
        return l10n.setPasscode;
      case PasscodeMode.confirm:
        return _isError ? l10n.passcodeMismatch : l10n.confirmPasscode;
    }
  }

  Future<void> _onDigit(int digit) async {
    if (_entered.length >= 6) return;
    setState(() {
      _entered += digit.toString();
    });

    if (_entered.length == 6) {
      await _handleComplete();
    }
  }

  void _onDelete() {
    if (_entered.isNotEmpty) {
      setState(() {
        _entered = _entered.substring(0, _entered.length - 1);
      });
    }
  }

  Future<void> _handleComplete() async {
    final l10n = AppLocalizations.of(context)!;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    switch (widget.mode) {
      case PasscodeMode.verify:
        final ok = await ref
            .read(securityNotifierProvider.notifier)
            .verifyPasscode(_entered);
        if (ok) {
          // unlock() was already called inside verifyPasscode; just pop
          if (mounted) navigator.pop();
        } else {
          setState(() => _isError = true);
          _shakeController.forward();
        }
        break;

      case PasscodeMode.set:
        navigator.pushReplacement(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (context, anim, secondAnim) => PasscodeScreen(
              mode: PasscodeMode.confirm,
              firstPasscode: _entered,
              onSuccess: widget.onSuccess,
            ),
            transitionsBuilder: (context, anim, secondAnim, child) {
              return FadeTransition(opacity: anim, child: child);
            },
          ),
        );
        break;

      case PasscodeMode.confirm:
        if (_entered == widget.firstPasscode) {
          await ref
              .read(securityNotifierProvider.notifier)
              .setPasscode(_entered);
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.passcodeSet)),
          );
          widget.onSuccess?.call();
          navigator.pop();
        } else {
          setState(() => _isError = true);
          _shakeController.forward();
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: AppTheme.backgroundDark.withOpacity(0.95),
          child: SafeArea(
            child: Column(
              children: [
                if (widget.mode != PasscodeMode.verify)
                  Align(
                    alignment: AlignmentDirectional.topStart,
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                const Spacer(),
                Text(
                  _title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 40),
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    final dx = _shakeAnimation.value *
                        ((_shakeController.value * 10).toInt().isEven
                            ? 1
                            : -1);
                    return Transform.translate(
                      offset: Offset(dx, 0),
                      child: child,
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (i) {
                      final filled = i < _entered.length;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
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
                            color: _isError
                                ? AppTheme.debtColor
                                : AppTheme.primaryColor,
                            width: 2,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const Spacer(),
                _buildNumpad(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumpad() {
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
                  children: _buildRow(row),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRow(int row) {
    if (row < 3) {
      return List.generate(3, (col) {
        final digit = row * 3 + col + 1;
        return _NumpadButton(
          label: digit.toString(),
          onTap: () => _onDigit(digit),
        );
      });
    }
    // Last row: biometric, 0, delete
    final security = ref.watch(securityNotifierProvider);
    return [
      if (security.isBiometricEnabled && widget.mode == PasscodeMode.verify)
        _NumpadButton(
          icon: Icons.fingerprint_rounded,
          onTap: () async {
            await ref
                .read(securityNotifierProvider.notifier)
                .checkBiometric();
            if (mounted &&
                !ref.read(securityNotifierProvider).isLocked) {
              Navigator.of(context).pop();
            }
          },
        )
      else
        const SizedBox(width: 72, height: 72),
      _NumpadButton(
        label: '0',
        onTap: () => _onDigit(0),
      ),
      _NumpadButton(
        icon: Icons.backspace_rounded,
        onTap: _onDelete,
      ),
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
          border: Border.all(
            color: AppTheme.borderDark.withOpacity(0.3),
          ),
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
              : Icon(
                  icon,
                  color: Colors.white.withOpacity(0.7),
                  size: 24,
                ),
        ),
      ),
    );
  }
}
