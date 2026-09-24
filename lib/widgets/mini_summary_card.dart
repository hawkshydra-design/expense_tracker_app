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
    final textColor = isDark ? AppColors.kTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.kTextSecondary : AppColors.lightTextSecondary;
    final cardColor = isDark ? AppColors.kSurface : AppColors.lightCard;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.kCardBorder : AppColors.lightBorder.withValues(alpha: 0.5),
        ),
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
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: amount),
            duration: AppDurations.countUp,
            curve: Curves.easeOut,
            builder: (context, value, _) {
              return Text(
                context.read<CurrencyProvider>().format(value),
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              );
            },
          ),
        ],
      ),
    );
  }
}
