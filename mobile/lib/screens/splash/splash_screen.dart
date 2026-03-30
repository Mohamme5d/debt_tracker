import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/security_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _fadeController;

  late Animation<double> _scaleAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
    ]).animate(_scaleController);

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _runAnimations();
  }

  Future<void> _runAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    await authProvider.initialize();

    if (!mounted) return;

    if (!authProvider.isLoggedIn) {
      context.go('/login');
      return;
    }

    final lockEnabled = await SecurityService().isLockEnabled();
    if (!mounted) return;

    if (lockEnabled) {
      context.go('/lock');
    } else {
      context.go('/dashboard');
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D1B2A), Color(0xFF1E293B)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnim,
                child: const _AppLogo(),
              ),
              const SizedBox(height: 32),
              SlideTransition(
                position: _slideAnim,
                child: const Text(
                  'إيجاري',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              SlideTransition(
                position: _slideAnim,
                child: const Text(
                  'Ijari',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FadeTransition(
                opacity: _fadeAnim,
                child: const Text(
                  'إدارة الإيجارات بسهولة',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppLogo extends StatelessWidget {
  const _AppLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(28),
      ),
      child: CustomPaint(
        painter: _HouseKeyPainter(),
      ),
    );
  }
}

class _HouseKeyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // House body
    final bodyRect = Rect.fromCenter(
      center: Offset(cx, cy + 2),
      width: 56,
      height: 38,
    );
    canvas.drawRect(bodyRect, paint);

    // Roof
    final roofPath = Path()
      ..moveTo(cx, cy - 30)
      ..lineTo(cx - 34, cy - 6)
      ..lineTo(cx + 34, cy - 6)
      ..close();
    canvas.drawPath(roofPath, paint);

    // Door (blue cutout)
    final doorPaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 14), width: 14, height: 20),
        const Radius.circular(3),
      ),
      doorPaint,
    );

    // Key
    final keyPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final keyFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Key ring
    canvas.drawCircle(Offset(cx - 10, cy + 34), 8, keyPaint);
    // Key shaft
    canvas.drawRect(
      Rect.fromLTWH(cx - 2, cy + 30, 30, 8),
      keyFill,
    );
    // Key teeth
    canvas.drawRect(Rect.fromLTWH(cx + 18, cy + 38, 5, 6), keyFill);
    canvas.drawRect(Rect.fromLTWH(cx + 24, cy + 38, 5, 4), keyFill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
