import 'package:flutter/material.dart';

/// App name wordmark: "Raseed" in English + "رصيد" in Arabic.
/// Used in splash and app bar.
class RaseedWordmark extends StatelessWidget {
  const RaseedWordmark({super.key, this.size = 28});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Raseed',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: size,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        Text(
          '\u0631\u0635\u064A\u062F',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: size * 0.55,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
