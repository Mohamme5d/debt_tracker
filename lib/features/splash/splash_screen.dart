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
              child: Text(
                '\u062A\u062A\u0628\u0639 \u062F\u064A\u0648\u0646\u0643 \u0628\u0630\u0643\u0627\u0621',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.4),
                  letterSpacing: 0.5,
                ),
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
            '\u0645\u0646 \u0631\u0635\u064A\u062F \u0628\u062B\u0642\u0629',
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
