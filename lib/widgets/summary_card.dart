import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import '../utils/constants.dart';

/// Summary card for displaying aggregate values on dashboard.
class SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Gradient gradient;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: borderColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(title, style: TextStyle(color: subtitleColor, fontSize: 12)),
          const SizedBox(height: 2),
          Text(
            context.read<CurrencyProvider>().format(amount),
            style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
