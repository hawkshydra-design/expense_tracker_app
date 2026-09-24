import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Frosted glass container for navigation chrome surfaces.
/// Real BackdropFilter blur with translucent fill + thin border.
/// Falls back to solid surface when accessibility reduce-motion is on
/// or when [forceOpaque] is true (for low-end GPU devices).
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? borderColor;
  final Color? backgroundColor;
  final bool forceOpaque;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.borderColor,
    this.backgroundColor,
    this.forceOpaque = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(borderRadius ?? AppRadius.lg);
    final shouldReduce = forceOpaque ||
        MediaQuery.of(context).disableAnimations;

    // ─── Solid fallback (accessibility / low-end GPU) ─────
    if (shouldReduce || backgroundColor != null) {
      return Container(
        margin: margin,
        padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: backgroundColor ??
              (isDark ? AppColors.kSurface : AppColors.lightCard),
          borderRadius: radius,
          border: Border.all(
            color: borderColor ??
                (isDark
                    ? AppColors.kCardBorder
                    : AppColors.lightBorder.withValues(alpha: 0.5)),
            width: 1,
          ),
        ),
        child: child,
      );
    }

    // ─── Real glass — BackdropFilter + translucent fill ───
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: isDark ? GlassTokens.blurDark : GlassTokens.blurLight,
            sigmaY: isDark ? GlassTokens.blurDark : GlassTokens.blurLight,
          ),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: isDark ? GlassTokens.fillDark : GlassTokens.fillLight,
              ),
              borderRadius: radius,
              border: Border.all(
                color: borderColor ??
                    Colors.white.withValues(
                      alpha: isDark
                          ? GlassTokens.borderDark
                          : GlassTokens.borderLight,
                    ),
                width: 0.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
