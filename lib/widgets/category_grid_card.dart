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
  final double total;
  final int transactionCount;

  const CategoryGridCard({
    super.key,
    required this.category,
    required this.amount,
    required this.total,
    required this.transactionCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.kTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.kTextSecondary : AppColors.lightTextSecondary;
    final cardColor = isDark ? AppColors.kSurface : AppColors.lightCard;
    final borderColor = isDark ? AppColors.kCardBorder : AppColors.lightBorder;
    final catColors = AppColors.categoryGradients[category.index];
    final percentage = total > 0 ? (amount / total * 100) : 0.0;

    final isMobile = AppBreakpoints.isMobile(context);
    final cardPadding = isMobile ? 10.0 : AppSpacing.md;

    return Container(
      padding: EdgeInsets.all(cardPadding),
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
          SizedBox(height: isMobile ? AppSpacing.sm : AppSpacing.md),
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
          SizedBox(height: isMobile ? 6.0 : AppSpacing.sm),
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
