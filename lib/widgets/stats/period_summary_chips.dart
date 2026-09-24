import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/currency_provider.dart';
import '../../utils/constants.dart';

/// Horizontal row of period summary chips (Today / Week / Month).
/// Used at the top of the Stats screen to show quick totals.
class PeriodSummaryChips extends StatelessWidget {
  final double todayAmount;
  final double weekAmount;
  final double monthAmount;
  final Color accentColor;

  const PeriodSummaryChips({
    super.key,
    required this.todayAmount,
    required this.weekAmount,
    required this.monthAmount,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.kTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor =
        isDark ? AppColors.kTextSecondary : AppColors.lightTextSecondary;
    final currencyProvider = context.read<CurrencyProvider>();

    return Row(
      children: [
        Expanded(
          child: _PeriodChip(
            label: 'Today',
            amount: currencyProvider.format(todayAmount),
            color: accentColor,
            textColor: textColor,
            subtitleColor: subtitleColor,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _PeriodChip(
            label: 'This Week',
            amount: currencyProvider.format(weekAmount),
            color: accentColor,
            textColor: textColor,
            subtitleColor: subtitleColor,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _PeriodChip(
            label: 'This Month',
            amount: currencyProvider.format(monthAmount),
            color: accentColor,
            textColor: textColor,
            subtitleColor: subtitleColor,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final Color textColor;
  final Color subtitleColor;
  final bool isDark;

  const _PeriodChip({
    required this.label,
    required this.amount,
    required this.color,
    required this.textColor,
    required this.subtitleColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.1 : 0.06),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: subtitleColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
