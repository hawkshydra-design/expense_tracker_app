import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Row of quick action chips for the dashboard.
class QuickActionRow extends StatelessWidget {
  final VoidCallback onAddExpense;
  final VoidCallback onAddIncome;
  final VoidCallback? onSync;

  const QuickActionRow({
    super.key,
    required this.onAddExpense,
    required this.onAddIncome,
    this.onSync,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _ActionChip(
            icon: Icons.add_circle_outline_rounded,
            label: 'Add Expense',
            color: AppColors.expense,
            onTap: onAddExpense,
            isDark: isDark,
          ),
          const SizedBox(width: AppSpacing.sm),
          _ActionChip(
            icon: Icons.add_circle_outline_rounded,
            label: 'Add Income',
            color: AppColors.income,
            onTap: onAddIncome,
            isDark: isDark,
          ),
          if (onSync != null) ...[
            const SizedBox(width: AppSpacing.sm),
            _ActionChip(
              icon: Icons.sync_rounded,
              label: 'Sync',
              color: AppColors.accent,
              onTap: onSync!,
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.2 : 0.15),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
