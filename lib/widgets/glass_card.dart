import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Glassmorphism card with frosted blur effect and subtle border.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final double? blur;
  final Color? borderColor;
  final Gradient? gradient;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur,
    this.borderColor,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? AppRadius.xl;
    final blurAmount = blur ?? (isDark ? GlassTokens.blurDark : GlassTokens.blurLight);

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: gradient ??
                  LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            Colors.white.withValues(alpha: GlassTokens.opacityDark),
                            Colors.white.withValues(alpha: GlassTokens.opacityDark * 0.5),
                          ]
                        : [
                            Colors.white.withValues(alpha: GlassTokens.opacityLight),
                            Colors.white.withValues(alpha: GlassTokens.opacityLight * 0.8),
                          ],
                  ),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: borderColor ??
                    (isDark
                        ? Colors.white.withValues(alpha: GlassTokens.borderOpacityDark)
                        : Colors.black.withValues(alpha: 0.06)),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
