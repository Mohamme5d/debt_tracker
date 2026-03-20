import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/raseed_logo.dart';
import '../../core/widgets/raseed_wordmark.dart';
import '../../app/theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _taglineOpacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.65, 0.9, curve: Curves.easeIn),
      ),
    );

    _ctrl.forward();

    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) context.go('/');
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated logo
            AnimatedBuilder(
              animation: _ctrl,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoOpacity.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: const RaseedLogo(size: 100),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // Wordmark
            AnimatedBuilder(
              animation: _ctrl,
              builder: (context, child) {
                return Opacity(
                  opacity: _textOpacity.value,
                  child: SlideTransition(
                    position: _textSlide,
                    child: child,
                  ),
                );
              },
              child: const RaseedWordmark(size: 36),
            ),
            const SizedBox(height: 16),
            // Tagline
            AnimatedBuilder(
              animation: _ctrl,
              builder: (context, child) {
                return Opacity(
                  opacity: _taglineOpacity.value,
                  child: child,
                );
              },
              child: Builder(
                builder: (context) {
                  final isAr = Localizations.localeOf(context).languageCode == 'ar';
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isAr ? 'تتبع ديونك بذكاء وثقة' : 'Track debts smartly & confidently',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          color: Colors.white.withValues(alpha: 0.4),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isAr ? 'سريع • آمن • بسيط' : 'Fast • Secure • Simple',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.3),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 40),
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, child) => Opacity(
            opacity: _taglineOpacity.value,
            child: child,
          ),
          child: Text(
            'v1.0.0 • رصيد',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
        ),
      ),
    );
  }
}
