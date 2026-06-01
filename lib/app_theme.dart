import 'package:flutter/material.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  static const primary = Color(0xFF1A1A2E);       // deep navy
  static const accent = Color(0xFFE94560);        // vivid red-pink
  static const accentAlt = Color(0xFF0F3460);     // mid navy
  static const surface = Color(0xFFF8F9FF);
  static const card = Colors.white;
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const inputFill = Color(0xFFF1F3FF);
  static const divider = Color(0xFFE5E7EB);
  static const success = Color(0xFF10B981);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);

  // Subject palette
  static const purple = Color(0xFF6C63FF);
  static const teal = Color(0xFF43AA8B);
  static const coral = Color(0xFFFF6B6B);
}

// ── Theme ──────────────────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          primary: AppColors.accent,
          onPrimary: Colors.white,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.surface,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.inputFill,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.accent, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700),
            elevation: 0,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.card,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
        ),
      );
}