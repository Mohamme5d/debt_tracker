import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 2025 Fintech Color System
  static const Color backgroundDark = Color(0xFF0D1B2A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceDark2 = Color(0xFF0F172A);
  static const Color borderDark = Color(0xFF334155);

  static const Color primaryColor = Color(0xFF2563EB);
  static const Color loanColor = Color(0xFF10B981);
  static const Color debtColor = Color(0xFFF43F5E);
  static const Color overdueColor = Color(0xFFF59E0B);
  static const Color settledColor = Color(0xFF64748B);

  // Legacy alias
  static const Color surfaceColor = backgroundDark;

  static const cardGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
  );

  static List<BoxShadow> get cardShadow => [
        const BoxShadow(
          color: Color(0x40000000),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ];

  static BoxDecoration get glassCardDecoration => BoxDecoration(
        gradient: cardGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderDark, width: 1),
        boxShadow: cardShadow,
      );

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      surface: backgroundDark,
      onSurface: Colors.white,
      primary: primaryColor,
      error: debtColor,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundDark,
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: surfaceDark,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF0F172A),
        indicatorColor: primaryColor.withOpacity(0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryColor, size: 24);
          }
          return IconThemeData(color: Colors.white.withOpacity(0.5), size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }
          return TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
          );
        }),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 72,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: debtColor, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return primaryColor.withOpacity(0.2);
            }
            return surfaceDark;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return primaryColor;
            }
            return Colors.white.withOpacity(0.5);
          }),
          side: WidgetStateProperty.all(
            const BorderSide(color: borderDark),
          ),
        ),
      ),
      dividerColor: borderDark,
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: const TextStyle(color: Colors.white),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryColor;
          return Colors.white.withOpacity(0.5);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor.withOpacity(0.3);
          }
          return borderDark;
        }),
      ),
    );
  }

  static ThemeData get lightTheme => darkTheme;

  /// Generates a gradient color pair based on a string hash.
  static List<Color> avatarGradient(String name) {
    final hash = name.hashCode;
    final hue = (hash % 360).abs().toDouble();
    return [
      HSLColor.fromAHSL(1.0, hue, 0.6, 0.5).toColor(),
      HSLColor.fromAHSL(1.0, (hue + 40) % 360, 0.7, 0.55).toColor(),
    ];
  }
}
