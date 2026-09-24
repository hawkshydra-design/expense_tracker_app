import 'package:flutter/material.dart';
import 'constants.dart';

/// BuildContext extension to eliminate repeated isDark / color lookups.
///
/// Instead of:
///   final isDark = Theme.of(context).brightness == Brightness.dark;
///   final textColor = isDark ? AppColors.kTextPrimary : AppColors.lightTextPrimary;
///
/// Use:
///   final textColor = context.textPrimary;
extension AppThemeX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // ─── Text Colors ─────────────────────────────────────────
  Color get textPrimary =>
      isDark ? AppColors.kTextPrimary : AppColors.lightTextPrimary;

  Color get textSecondary =>
      isDark ? AppColors.kTextSecondary : AppColors.lightTextSecondary;

  Color get textMuted =>
      isDark ? AppColors.kTextMuted : AppColors.lightTextMuted;

  // ─── Surface Colors ──────────────────────────────────────
  Color get cardColor => isDark ? AppColors.kSurface : AppColors.lightCard;

  Color get cardAltColor =>
      isDark ? AppColors.kSurface : AppColors.lightCardAlt;

  Color get surfaceColor =>
      isDark ? AppColors.kSurface : AppColors.lightSurface;

  Color get bgColor => isDark ? AppColors.kBackground : AppColors.lightBg;

  // ─── Border Colors ───────────────────────────────────────
  Color get borderColor =>
      isDark ? AppColors.kCardBorder : AppColors.lightBorder;

  Color get borderSubtle => isDark
      ? AppColors.kCardBorder
      : AppColors.lightBorder;

  // ─── Convenience ─────────────────────────────────────────
  double get horizontalPadding => AppBreakpoints.horizontalPadding(this);

  bool get isMobile => AppBreakpoints.isMobile(this);

  bool get isDesktop => AppBreakpoints.isDesktop(this);

  double get maxContentWidth => AppBreakpoints.maxContentWidth(this);
}
