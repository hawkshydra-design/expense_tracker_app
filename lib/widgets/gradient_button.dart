import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'bounce_tap.dart';

/// Animated gradient button with loading state and BounceTap feedback.
/// Replaces 5 duplicated gradient button blocks across auth screens.
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Gradient? gradient;
  final IconData? icon;
  final double? width;
  final double height;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.gradient,
    this.icon,
    this.width,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;

    return BounceTap(
      onTap: enabled ? onPressed : null,
      enableHaptic: enabled,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: enabled
              ? (gradient ?? AppColors.primaryGradient)
              : LinearGradient(
                  colors: [Colors.grey.shade700, Colors.grey.shade800],
                ),
          borderRadius: BorderRadius.circular(AppRadius.button),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.kViolet.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20, color: Colors.white),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Text(
                      text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
