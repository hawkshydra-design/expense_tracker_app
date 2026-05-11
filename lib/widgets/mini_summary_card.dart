import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import '../utils/constants.dart';

/// A compact summary card showing a spending metric.
/// Extracted from HomeScreen for reusability.
class MiniSummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final Gradient gradient;
  final IconData icon;

  const MiniSummaryCard({
    super.key,
    required this.label,
    required this.amount,
    required this.gradient,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
            color: borderColor.withValues(alpha: isDark ? 0.3 : 0.5)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(label,
              style: TextStyle(
                  color: subtitleColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(
            context.read<CurrencyProvider>().format(amount),
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
