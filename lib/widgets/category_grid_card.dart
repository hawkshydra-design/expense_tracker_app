import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/currency_provider.dart';
import '../utils/constants.dart';

/// Category spending grid card (for the Stats/Categories view).
/// Shows category icon, name, transaction count, amount, and percentage.
class CategoryGridCard extends StatelessWidget {
  final ExpenseCategory category;
  final double amount;
  final int transactionCount;
  final double percentage;

  const CategoryGridCard({
    super.key,
    required this.category,
    required this.amount,
    required this.transactionCount,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final catColors = AppColors.categoryGradients[category.index];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: borderColor.withValues(alpha: isDark ? 0.3 : 0.5),
        ),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon + percentage badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: catColors),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(category.icon, color: Colors.white, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: catColors[0].withValues(alpha: isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: catColors[0],
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Name + count
          Text(
            category.label,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$transactionCount Transactions',
            style: TextStyle(
              color: subtitleColor,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Amount
          Flexible(
            child: Text(
              '-${context.read<CurrencyProvider>().format(amount)}',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
