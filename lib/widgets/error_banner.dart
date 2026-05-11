import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Animated error banner for consistent error display across screens.
class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;

  const ErrorBanner({
    super.key,
    required this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedSize(
      duration: AppDurations.normal,
      child: message.isEmpty
          ? const SizedBox.shrink()
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.error.withValues(alpha: 0.15)
                    : AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: isDark ? AppColors.errorLight : AppColors.error,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (onDismiss != null)
                    GestureDetector(
                      onTap: onDismiss,
                      child: Icon(
                        Icons.close_rounded,
                        color: isDark ? AppColors.errorLight : AppColors.error,
                        size: 18,
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
