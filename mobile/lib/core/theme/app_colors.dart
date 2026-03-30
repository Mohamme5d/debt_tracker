import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Backgrounds ──────────────────────────────────────────────────────────
  static const bgPage  = Color(0xFF0D1B2A); // deep navy
  static const surface = Color(0xFF1E293B); // card surface
  static const surface2 = Color(0xFF0F172A); // secondary surface
  static const border  = Color(0xFF334155); // dividers / input borders

  // ── Brand ────────────────────────────────────────────────────────────────
  static const primary      = Color(0xFF2563EB);
  static const primaryDark  = Color(0xFF1D4ED8);
  static const primaryLight = Color(0xFF3B82F6);

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const secondary = Color(0xFF06B6D4); // cyan  – deposits
  static const accent    = Color(0xFFF59E0B); // amber – accent
  static const success   = Color(0xFF10B981); // green – active / collected
  static const warning   = Color(0xFFF59E0B); // amber – outstanding
  static const danger    = Color(0xFFF43F5E); // red   – expenses / delete

  // ── Text ─────────────────────────────────────────────────────────────────
  static const textPrimary   = Colors.white;
  static const textSecondary = Color(0xFF94A3B8);

  // ── Gradients ────────────────────────────────────────────────────────────
  static const List<Color> gradientPrimary = [Color(0xFF2563EB), Color(0xFF1D4ED8)];
  static const List<Color> gradientDash    = [Color(0xFF1976D2), Color(0xFF0288D1)];
  static const List<Color> cardGradient    = [Color(0xFF1E293B), Color(0xFF0F172A)];

  // ── Card shadow ──────────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
        const BoxShadow(
          color: Color(0x40000000),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ];

  // ── Gradient avatar based on name hash ───────────────────────────────────
  static List<Color> avatarGradient(String name) {
    final hash = name.hashCode;
    final hue  = (hash % 360).abs().toDouble();
    return [
      HSLColor.fromAHSL(1.0, hue, 0.6, 0.5).toColor(),
      HSLColor.fromAHSL(1.0, (hue + 40) % 360, 0.7, 0.55).toColor(),
    ];
  }
}
