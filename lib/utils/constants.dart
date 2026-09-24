import 'package:flutter/material.dart';

/// ─── App Color Palette ──────────────────────────────────────
/// Obsidian + Rose Gold identity. Single source of truth.
/// Never use raw hex in widget files.
class AppColors {
  AppColors._();

  // ─── Core Background (Obsidian) ──────────────────────────
  static const Color kBackground = Color(0xFF0A0A0A);
  static const Color kSurface = Color(0xFF141414);
  static const Color kSurfaceLight = Color(0xFF1E1E1E);
  static Color kCardBorder = Colors.white.withValues(alpha: 0.06);

  // ─── Brand Accents (Rose Gold + Champagne) ───────────────
  static const Color kPrimary = Color(0xFFE8A87C);
  static const Color kPrimaryDark = Color(0xFFD4956A);
  static const Color kPrimaryLight = Color(0xFFF0C4A8);
  static const Color kAccent = Color(0xFFD4AF37);
  static const Color kCoral = Color(0xFFE76F51);
  static const Color kDustyRose = Color(0xFFC45B5B);
  static const Color kAmber = Color(0xFFF2A922);
  static const Color kGreen = Color(0xFF6BCB77);

  // ─── Legacy aliases — map old names to new palette ───────
  static const Color kViolet = kPrimary;
  static const Color kVioletDark = kPrimaryDark;
  static const Color kVioletLight = kPrimaryLight;
  static const Color kCyan = kAccent;
  static const Color kRose = kCoral;
  static const Color kPink = kDustyRose;

  // ─── Text Colors (warm-tinted) ───────────────────────────
  static const Color kTextPrimary = Color(0xFFF5F0EB);
  static const Color kTextSecondary = Color(0xFFA09890);
  static const Color kTextMuted = Color(0xFF605850);

  // ─── Legacy aliases (dark mode) ──────────────────────────
  static const Color darkBg = kBackground;
  static const Color darkSurface = kSurface;
  static const Color darkCard = kSurface;
  static const Color darkCardAlt = kSurfaceLight;
  static Color darkBorder = kCardBorder;
  static const Color darkTextPrimary = kTextPrimary;
  static const Color darkTextSecondary = kTextSecondary;
  static const Color darkTextMuted = kTextMuted;

  // ─── Light mode (Warm Cream) ─────────────────────────────
  static const Color lightBg = Color(0xFFFAF6F1);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardAlt = Color(0xFFF3EDE6);
  static const Color lightBorder = Color(0xFFD4C4B0);
  static const Color lightTextPrimary = Color(0xFF2C2420);
  static const Color lightTextSecondary = Color(0xFF6E5E52);
  static const Color lightTextMuted = Color(0xFF9A8A7E);

  // ─── Semantic Colors ─────────────────────────────────────
  static const Color primary = kPrimary;
  static const Color primaryDark = kPrimaryDark;
  static const Color primaryLight = kPrimaryLight;
  static const Color primarySoft = Color(0xFF2E1E14);
  static const Color accent = kAccent;
  static const Color accentDark = Color(0xFFB8941F);

  static const Color income = kGreen;
  static const Color incomeDark = Color(0xFF52B562);
  static const Color expense = kCoral;
  static const Color expenseDark = Color(0xFFD45D3F);

  static const Color success = kGreen;
  static const Color successLight = Color(0xFF8ED89A);
  static const Color warning = kAmber;
  static const Color warningLight = Color(0xFFF5C34A);
  static const Color error = kDustyRose;
  static const Color errorLight = kCoral;

  // ─── Category Gradient Pairs ─────────────────────────────
  static const List<List<Color>> categoryGradients = [
    [Color(0xFFE76F51), Color(0xFFD45D3F)], // Food — warm coral
    [Color(0xFFD4AF37), Color(0xFFB8941F)], // Transport — champagne gold
    [Color(0xFFE8A87C), Color(0xFFD4956A)], // Shopping — rose gold
    [Color(0xFF6BCB77), Color(0xFF52B562)], // Bills — sage green
    [Color(0xFFC084FC), Color(0xFFA855F7)], // Entertainment — soft lavender
    [Color(0xFFF0C4A8), Color(0xFFE8A87C)], // Health — blush rose
    [Color(0xFF60A5FA), Color(0xFF3B82F6)], // Education — steel blue
    [Color(0xFFA09890), Color(0xFF807870)], // Other — warm silver
  ];

  // ─── Category Solid Colors (for charts) ──────────────────
  static const List<Color> categoryChartColors = [
    Color(0xFFE76F51), // Food
    Color(0xFFD4AF37), // Transport
    Color(0xFFE8A87C), // Shopping
    Color(0xFF6BCB77), // Bills
    Color(0xFFC084FC), // Entertainment
    Color(0xFFF0C4A8), // Health
    Color(0xFF60A5FA), // Education
    Color(0xFFA09890), // Other
  ];

  // ─── Gradient Definitions ────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [kPrimary, kPrimaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [kAccent, Color(0xFFB8941F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [kGreen, Color(0xFF52B562)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [kCoral, kDustyRose],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient balanceGradient = LinearGradient(
    colors: [Color(0xFF0A0A0A), Color(0xFF1E1410), kPrimary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient incomeGradient = LinearGradient(
    colors: [kGreen, Color(0xFF52B562)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [kCoral, Color(0xFFD45D3F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient meshGradient = LinearGradient(
    colors: [kPrimary, kCoral, kAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Legacy color references used by misc files ──────────
  static const Color accentYellow = kAmber;
  static const Color accentYellowDark = Color(0xFFD4960A);
  static const Color gradientBlue = kPrimary;
  static const Color gradientPurple = kPrimaryLight;
  static const Color gradientCyan = kAccent;
  static const Color gradientPink = kCoral;
  static const Color gradientTeal = kGreen;
}

/// ─── Glassmorphism Tokens ───────────────────────────────────
/// Per liquid-glass-js guide: blur 15–25px, subtle fill, thin border.
class GlassTokens {
  GlassTokens._();

  static const double blurDark = 18.0;
  static const double blurLight = 15.0;
  static const double fillDark = 0.06;
  static const double fillLight = 0.40;
  static const double borderDark = 0.10;
  static const double borderLight = 0.60;
  static const double shadowBlur = 12.0;
  static const double shadowOpacity = 0.15;
}

/// ─── M3 Expressive Shape Tokens ─────────────────────────────
/// Asymmetric radii per component type. Consistency > randomness.
class ExpressiveShapes {
  ExpressiveShapes._();

  /// Hero cards (balance card): bold asymmetric
  static const BorderRadius heroCard = BorderRadius.only(
    topLeft: Radius.circular(32),
    topRight: Radius.circular(12),
    bottomLeft: Radius.circular(12),
    bottomRight: Radius.circular(32),
  );

  /// Category tiles: alternating A pattern
  static const BorderRadius tileA = BorderRadius.only(
    topLeft: Radius.circular(24),
    topRight: Radius.circular(8),
    bottomLeft: Radius.circular(8),
    bottomRight: Radius.circular(24),
  );

  /// Category tiles: alternating B pattern (mirror of A)
  static const BorderRadius tileB = BorderRadius.only(
    topLeft: Radius.circular(8),
    topRight: Radius.circular(24),
    bottomLeft: Radius.circular(24),
    bottomRight: Radius.circular(8),
  );

  /// Standard content cards
  static const double contentCard = 16.0;

  /// Glass chrome (nav bar, modals)
  static const double glassCapsule = 28.0;
}

/// ─── Spring Animation Tokens ────────────────────────────────
/// Guide cap: ~6px amplitude. Subtle, not bouncy.
class SpringTokens {
  SpringTokens._();

  static const double tapScale = 0.97;
  static const Duration duration = Duration(milliseconds: 200);
  static const Curve curve = Curves.easeOutBack;
}

/// ─── Animation Durations ────────────────────────────────────
class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration enter = Duration(milliseconds: 300);
  static const Duration exit = Duration(milliseconds: 200);
  static const Duration tap = Duration(milliseconds: 400);
  static const Duration countUp = Duration(milliseconds: 600);
  static const Duration colorMorph = Duration(milliseconds: 250);
  static const Duration pageTransition = Duration(milliseconds: 350);
  static const Duration staggerDelay = Duration(milliseconds: 60);
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

/// ─── Border Radius Tokens ───────────────────────────────────
class AppRadius {
  AppRadius._();

  static const double badge = 6.0;
  static const double sm = 8.0;
  static const double input = 12.0;
  static const double md = 12.0;
  static const double button = 14.0;
  static const double lg = 16.0;
  static const double chip = 20.0;
  static const double xl = 24.0;
  static const double nav = 28.0;
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

/// ─── Shadows (Rose Gold tinted) ─────────────────────────────
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get softDark => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.5),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: AppColors.kPrimary.withValues(alpha: 0.06),
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
      ];

  static List<BoxShadow> get glowPrimary => [
        BoxShadow(
          color: AppColors.kPrimary.withValues(alpha: 0.3),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get glowViolet => [
        BoxShadow(
          color: AppColors.kPrimary.withValues(alpha: 0.4),
          blurRadius: 20,
          spreadRadius: -4,
        ),
      ];

  static List<BoxShadow> get cardDark => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.5),
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
