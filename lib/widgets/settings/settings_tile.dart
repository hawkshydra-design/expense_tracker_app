import 'package:flutter/material.dart';
import '../../utils/constants.dart';

/// Reusable tile widget used across all settings sections.
///
/// Displays an icon, title, subtitle, and a trailing widget
/// (typically a switch, chevron, or status indicator).
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final Color? titleColor;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = titleColor ??
        (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);
    final subtitleTextColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: subtitleTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
