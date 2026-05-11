import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Category filter chip — used on stats filters.
class CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.2)
              : (isDark ? AppColors.darkCardAlt : AppColors.lightCardAlt),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder).withValues(alpha: 0.4),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? color : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
