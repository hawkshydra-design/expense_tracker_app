import 'package:flutter/material.dart';

/// ─── App Color Palette ──────────────────────────────────────
class AppColors {
  AppColors._();

  // ─── Dark Mode Colors ────────────────────────────────────
  static const Color darkBg = Color(0xFF0D1117);
  static const Color darkSurface = Color(0xFF161B22);
  static const Color darkCard = Color(0xFF1C2333);
  static const Color darkCardAlt = Color(0xFF232D3F);
  static const Color darkBorder = Color(0xFF2A3545);

  // ─── Light Mode Colors ───────────────────────────────────
  static const Color lightBg = Color(0xFFF5F5FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardAlt = Color(0xFFF0F0F8);
  static const Color lightBorder = Color(0xFFE0E0EE);

  // ─── Brand Colors ────────────────────────────────────────
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF4834DF);
  static const Color primaryLight = Color(0xFF8B83FF);
  static const Color primarySoft = Color(0xFFE8E6FF);
  static const Color accent = Color(0xFF00D2FF);
  static const Color accentDark = Color(0xFF00A3CC);

  // ─── Income / Expense Colors ─────────────────────────────
  static const Color income = Color(0xFF4ADE80);
  static const Color incomeDark = Color(0xFF22C55E);
  static const Color expense = Color(0xFFFF6B6B);
  static const Color expenseDark = Color(0xFFEF4444);
  static const Color accentYellow = Color(0xFFCDDC39);
  static const Color accentYellowDark = Color(0xFFAFB42B);

  // ─── Gradient Mesh Colors ────────────────────────────────
  static const Color gradientBlue = Color(0xFF6C63FF);
  static const Color gradientPurple = Color(0xFF9B59B6);
  static const Color gradientCyan = Color(0xFF00D2FF);
  static const Color gradientPink = Color(0xFFFF6B9D);
  static const Color gradientTeal = Color(0xFF4ECDC4);

  // ─── Text Colors ─────────────────────────────────────────
  static const Color darkTextPrimary = Color(0xFFF0EEFF);
  static const Color darkTextSecondary = Color(0xFFB0ADCF);
  static const Color darkTextMuted = Color(0xFF6E6A8E);

  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF5A5A7A);
  static const Color lightTextMuted = Color(0xFF9A9AB0);

  // ─── Status / Feedback Colors ────────────────────────────
  static const Color success = Color(0xFF4ECDC4);
  static const Color successLight = Color(0xFF7EDDD7);
  static const Color warning = Color(0xFFFFBE21);
  static const Color warningLight = Color(0xFFFFD66B);
  static const Color error = Color(0xFFFF6B6B);
  static const Color errorLight = Color(0xFFFF9B9B);

  // ─── Category Gradient Pairs ─────────────────────────────
  static const List<List<Color>> categoryGradients = [
    [Color(0xFFFF6B6B), Color(0xFFEE5A24)], // Food
    [Color(0xFF4ECDC4), Color(0xFF2CA8A0)], // Transport
    [Color(0xFFFFBE21), Color(0xFFF0932B)], // Shopping
    [Color(0xFF7ED6DF), Color(0xFF22A6B3)], // Bills
    [Color(0xFFDDA0DD), Color(0xFFBE2EDD)], // Entertainment
    [Color(0xFFFF6B9D), Color(0xFFE55D87)], // Health
    [Color(0xFF82B1FF), Color(0xFF4A6CF7)], // Education
    [Color(0xFFB0BEC5), Color(0xFF78909C)], // Other
  ];

  // ─── Category Solid Colors (for charts) ──────────────────
  static const List<Color> categoryChartColors = [
    Color(0xFFFF6B6B), // Food
    Color(0xFF4ECDC4), // Transport
    Color(0xFFFFBE21), // Shopping
    Color(0xFF7ED6DF), // Bills
    Color(0xFFDDA0DD), // Entertainment
    Color(0xFFFF6B9D), // Health
    Color(0xFF82B1FF), // Education
    Color(0xFFB0BEC5), // Other
  ];

  // ─── Gradient Definitions ────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF4834DF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00D2FF), Color(0xFF6C63FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF4ECDC4), Color(0xFF2BAD8E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFF6B9D), Color(0xFFFF8E53)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient balanceGradient = LinearGradient(
    colors: [Color(0xFF1A1A3E), Color(0xFF2D1B69), Color(0xFF11998E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF4ADE80), Color(0xFF22C55E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient meshGradient = LinearGradient(
    colors: [
      Color(0xFF6C63FF),
      Color(0xFF9B59B6),
      Color(0xFF00D2FF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// ─── Glassmorphism Tokens ───────────────────────────────────
class GlassTokens {
  GlassTokens._();

  static const double blurDark = 24.0;
  static const double blurLight = 16.0;
  static const double opacityDark = 0.15;
  static const double opacityLight = 0.7;
  static const double borderOpacityDark = 0.15;
  static const double borderOpacityLight = 0.3;
}

/// ─── Animation Durations ────────────────────────────────────
class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration pageTransition = Duration(milliseconds: 400);
  static const Duration staggerDelay = Duration(milliseconds: 80);
  static const Duration splashDuration = Duration(milliseconds: 2500);
  static const Duration fabExpand = Duration(milliseconds: 250);
}

/// ─── Spacing & Sizing ───────────────────────────────────────
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

/// ─── Border Radius ──────────────────────────────────────────
class AppRadius {
  AppRadius._();

  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double full = 100.0;
}

/// ─── Responsive Breakpoints ─────────────────────────────────
class AppBreakpoints {
  AppBreakpoints._();

  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= mobile && w < desktop;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop;

  /// Returns number of columns for grid layouts
  static int gridColumns(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return 3;
    return 2;
  }

  /// Returns horizontal padding based on screen size
  static double horizontalPadding(BuildContext context) {
    if (isDesktop(context)) return 48.0;
    if (isTablet(context)) return 32.0;
    return 20.0;
  }

  /// Max content width for desktop
  static double maxContentWidth(BuildContext context) {
    if (isDesktop(context)) return 1000.0;
    return double.infinity;
  }
}

/// ─── Shadows ────────────────────────────────────────────────
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get softDark => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.1),
          blurRadius: 40,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get softLight => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.06),
          blurRadius: 40,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get glowPrimary => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.3),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get cardDark => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.4),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
}

/// ─── String Constants ───────────────────────────────────────
class AppStrings {
  AppStrings._();

  static const String appName = 'Expense Tracker';
  static const String noExpenses =
      'No expenses yet!\nTap + to add your first expense.';
}
