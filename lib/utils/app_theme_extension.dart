import 'package:flutter/material.dart';
import 'constants.dart';

/// BuildContext extension to eliminate repeated isDark / color lookups.
///
/// Instead of:
///   final isDark = Theme.of(context).brightness == Brightness.dark;
///   final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
///
/// Use:
///   final textColor = context.textPrimary;
extension AppThemeX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // ─── Text Colors ─────────────────────────────────────────
  Color get textPrimary =>
      isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

  Color get textSecondary =>
      isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

  Color get textMuted =>
      isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

  // ─── Surface Colors ──────────────────────────────────────
  Color get cardColor => isDark ? AppColors.darkCard : AppColors.lightCard;

  Color get cardAltColor =>
      isDark ? AppColors.darkCardAlt : AppColors.lightCardAlt;

  Color get surfaceColor =>
      isDark ? AppColors.darkSurface : AppColors.lightSurface;

  Color get bgColor => isDark ? AppColors.darkBg : AppColors.lightBg;

  // ─── Border Colors ───────────────────────────────────────
  Color get borderColor =>
      isDark ? AppColors.darkBorder : AppColors.lightBorder;

  Color get borderSubtle => isDark
      ? AppColors.darkBorder.withValues(alpha: 0.3)
      : AppColors.lightBorder;

  // ─── Convenience ─────────────────────────────────────────
  double get horizontalPadding => AppBreakpoints.horizontalPadding(this);

  bool get isMobile => AppBreakpoints.isMobile(this);

  bool get isDesktop => AppBreakpoints.isDesktop(this);

  double get maxContentWidth => AppBreakpoints.maxContentWidth(this);
}
