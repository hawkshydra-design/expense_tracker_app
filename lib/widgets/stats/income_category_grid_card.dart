import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/income_category.dart';
import '../../providers/currency_provider.dart';
import '../../utils/constants.dart';

/// Grid card for displaying an income category's total and percentage.
class IncomeCategoryGridCard extends StatelessWidget {
  final IncomeCategory category;
  final double amount;
  final double total;
  final int transactionCount;

  const IncomeCategoryGridCard({
    super.key,
    required this.category,
    required this.amount,
    required this.total,
    required this.transactionCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.kTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor =
        isDark ? AppColors.kTextSecondary : AppColors.lightTextSecondary;
    final cardColor = isDark ? AppColors.kSurface : AppColors.lightCard;
    final borderColor = isDark ? AppColors.kCardBorder : AppColors.lightBorder;
    final percentage = total > 0 ? (amount / total * 100) : 0.0;
    final currencyProvider = context.read<CurrencyProvider>();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border:
            Border.all(color: borderColor.withValues(alpha: isDark ? 0.3 : 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + Percentage
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    category.color,
                    category.color.withValues(alpha: 0.7),
                  ]),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(category.icon, color: Colors.white, size: 20),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.kGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: AppColors.kGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Category name
          Text(
            category.label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Amount
          Text(
            '+${currencyProvider.format(amount)}',
            style: const TextStyle(
              color: AppColors.kGreen,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          // Transaction count
          Text(
            '$transactionCount transaction${transactionCount != 1 ? 's' : ''}',
            style: TextStyle(
              color: subtitleColor,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
