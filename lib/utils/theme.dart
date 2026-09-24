import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

class AppTheme {
  AppTheme._();

  // ─── Dark Theme (Default — Obsidian + Rose Gold) ─────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.kBackground,
      // Kill all Material ripple/splash globally
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.kPrimary,
        primaryContainer: AppColors.kPrimaryDark,
        secondary: AppColors.kAccent,
        secondaryContainer: AppColors.accentDark,
        surface: AppColors.kSurface,
        error: AppColors.kDustyRose,
        onPrimary: Color(0xFF1A1210),
        onSecondary: Color(0xFF1A1210),
        onSurface: AppColors.kTextPrimary,
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
      dividerTheme: DividerThemeData(
        color: AppColors.kCardBorder,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.kSurface,
        contentTextStyle: GoogleFonts.inter(color: AppColors.kTextPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.kSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      ),
    );
  }

  // ─── Light Theme (Warm Cream + Deep Rose Gold) ───────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFC4885C),
        primaryContainer: AppColors.kPrimaryLight,
        secondary: AppColors.kAccent,
        secondaryContainer: AppColors.accentDark,
        surface: AppColors.lightSurface,
        error: AppColors.kDustyRose,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      ),
    );
  }

  // ─── Text Theme ──────────────────────────────────────────
  static TextTheme _buildTextTheme({required bool isDark}) {
    final primary = isDark ? AppColors.kTextPrimary : AppColors.lightTextPrimary;
    final secondary = isDark ? AppColors.kTextSecondary : AppColors.lightTextSecondary;

    return GoogleFonts.interTextTheme(
      TextTheme(
        displayLarge: TextStyle(fontSize: 38, fontWeight: FontWeight.w700, color: primary, letterSpacing: -1),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.3),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: primary),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: primary),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: primary),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: secondary),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: primary),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: secondary),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: secondary),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primary),
        labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: secondary),
        labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.kTextMuted),
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
        color: isDark ? AppColors.kTextPrimary : AppColors.lightTextPrimary,
      ),
      iconTheme: IconThemeData(
        color: isDark ? AppColors.kTextPrimary : AppColors.lightTextPrimary,
      ),
    );
  }

  // ─── Card Theme ──────────────────────────────────────────
  static CardThemeData _buildCardTheme({required bool isDark}) {
    return CardThemeData(
      color: isDark ? AppColors.kSurface : AppColors.lightCard,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(
          color: isDark ? AppColors.kCardBorder : AppColors.lightBorder.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
    );
  }

  // ─── FAB Theme (Rose Gold) ───────────────────────────────
  static FloatingActionButtonThemeData _buildFabTheme() {
    return FloatingActionButtonThemeData(
      backgroundColor: AppColors.kPrimary,
      foregroundColor: const Color(0xFF1A1210),
      elevation: 0,
      highlightElevation: 0,
      splashColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
    );
  }

  // ─── Input Theme ─────────────────────────────────────────
  static InputDecorationTheme _buildInputTheme({required bool isDark}) {
    final fillColor = isDark ? AppColors.kSurface : AppColors.lightCardAlt;
    final borderColor = isDark ? AppColors.kCardBorder : AppColors.lightBorder;

    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : borderColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.kPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.kDustyRose, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.kDustyRose, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md + 2,
      ),
      hintStyle: TextStyle(
        color: isDark ? AppColors.kTextMuted : AppColors.lightTextMuted,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: TextStyle(
        color: isDark ? AppColors.kTextMuted : AppColors.lightTextMuted,
      ),
    );
  }

  // ─── Elevated Button Theme (Rose Gold) ───────────────────
  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.kPrimary,
        foregroundColor: const Color(0xFF1A1210),
        elevation: 0,
        splashFactory: NoSplash.splashFactory,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ─── Outlined Button Theme ───────────────────────────────
  static OutlinedButtonThemeData _buildOutlinedButtonTheme({required bool isDark}) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.kPrimary,
        side: const BorderSide(color: AppColors.kPrimary, width: 1.5),
        splashFactory: NoSplash.splashFactory,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ─── Text Button Theme ───────────────────────────────────
  static TextButtonThemeData _buildTextButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.kPrimary,
        splashFactory: NoSplash.splashFactory,
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ─── Bottom Nav Theme ────────────────────────────────────
  static BottomNavigationBarThemeData _buildBottomNavTheme({required bool isDark}) {
    return BottomNavigationBarThemeData(
      backgroundColor: isDark ? AppColors.kSurface : AppColors.lightSurface,
      selectedItemColor: AppColors.kPrimary,
      unselectedItemColor: isDark ? AppColors.kTextMuted : AppColors.lightTextMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    );
  }
}
