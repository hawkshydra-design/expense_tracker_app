import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../utils/constants.dart';
import 'bounce_tap.dart';

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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _ActionChip(
            icon: LucideIcons.minusCircle,
            label: 'Add Expense',
            color: AppColors.kRose,
            onTap: onAddExpense,
          ),
          const SizedBox(width: AppSpacing.sm),
          _ActionChip(
            icon: LucideIcons.plusCircle,
            label: 'Add Income',
            color: AppColors.kGreen,
            onTap: onAddIncome,
          ),
          if (onSync != null) ...[
            const SizedBox(width: AppSpacing.sm),
            _ActionChip(
              icon: LucideIcons.refreshCw,
              label: 'Sync',
              color: AppColors.kCyan,
              onTap: onSync!,
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

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BounceTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
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
    );
  }
}
