import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

class AppTheme {
  AppTheme._();

  // ─── Dark Theme ──────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryDark,
        secondary: AppColors.accent,
        secondaryContainer: AppColors.accentDark,
        surface: AppColors.darkSurface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.darkTextPrimary,
        onError: Colors.white,
      ),
      textTheme: _buildTextTheme(isDark: true),
      appBarTheme: _buildAppBarTheme(isDark: true),
      cardTheme: _buildCardTheme(isDark: true),
      floatingActionButtonTheme: _buildFabTheme(),
      inputDecorationTheme: _buildInputTheme(isDark: true),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(isDark: true),
      textButtonTheme: _buildTextButtonTheme(),
      bottomNavigationBarTheme: _buildBottomNavTheme(isDark: true),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkCard,
        contentTextStyle: GoogleFonts.inter(color: AppColors.darkTextPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
      ),
    );
  }

  // ─── Light Theme ─────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.accent,
        secondaryContainer: AppColors.accentDark,
        surface: AppColors.lightSurface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.lightTextPrimary,
        onError: Colors.white,
      ),
      textTheme: _buildTextTheme(isDark: false),
      appBarTheme: _buildAppBarTheme(isDark: false),
      cardTheme: _buildCardTheme(isDark: false),
      floatingActionButtonTheme: _buildFabTheme(),
      inputDecorationTheme: _buildInputTheme(isDark: false),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(isDark: false),
      textButtonTheme: _buildTextButtonTheme(),
      bottomNavigationBarTheme: _buildBottomNavTheme(isDark: false),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.lightCard,
        contentTextStyle: GoogleFonts.inter(color: AppColors.lightTextPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
      ),
    );
  }

  // ─── Text Theme ──────────────────────────────────────────
  static TextTheme _buildTextTheme({required bool isDark}) {
    final primary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return GoogleFonts.interTextTheme(
      TextTheme(
        displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: primary, letterSpacing: -0.5),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.3),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: primary),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: primary),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: primary),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: secondary),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: primary),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: secondary),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: secondary),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primary),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: secondary),
        labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: secondary),
      ),
    );
  }

  // ─── AppBar Theme ────────────────────────────────────────
  static AppBarTheme _buildAppBarTheme({required bool isDark}) {
    return AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      ),
      iconTheme: IconThemeData(
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      ),
    );
  }

  // ─── Card Theme ──────────────────────────────────────────
  static CardThemeData _buildCardTheme({required bool isDark}) {
    return CardThemeData(
      color: isDark ? AppColors.darkCard : AppColors.lightCard,
      elevation: isDark ? 0 : 2,
      shadowColor: isDark ? Colors.transparent : Colors.black.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: BorderSide(
          color: isDark
              ? AppColors.darkBorder.withValues(alpha: 0.3)
              : AppColors.lightBorder.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
    );
  }

  // ─── FAB Theme ───────────────────────────────────────────
  static FloatingActionButtonThemeData _buildFabTheme() {
    return FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
    );
  }

  // ─── Input Theme ─────────────────────────────────────────
  static InputDecorationTheme _buildInputTheme({required bool isDark}) {
    final fillColor = isDark ? AppColors.darkCardAlt : AppColors.lightCardAlt;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final hintColor = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide(color: borderColor.withValues(alpha: 0.5), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md + 2,
      ),
      hintStyle: TextStyle(color: hintColor, fontWeight: FontWeight.w400),
      labelStyle: TextStyle(color: hintColor),
    );
  }

  // ─── Elevated Button Theme ───────────────────────────────
  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ─── Outlined Button Theme ───────────────────────────────
  static OutlinedButtonThemeData _buildOutlinedButtonTheme({required bool isDark}) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ─── Text Button Theme ───────────────────────────────────
  static TextButtonThemeData _buildTextButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ─── Bottom Nav Theme ────────────────────────────────────
  static BottomNavigationBarThemeData _buildBottomNavTheme({required bool isDark}) {
    return BottomNavigationBarThemeData(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    );
  }
}
