import 'package:flutter/material.dart';

class RaseedLogo extends StatelessWidget {
  const RaseedLogo({super.key, this.size = 80});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '\u0631',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1,
          ),
        ),
      ),
    );
  }
}
