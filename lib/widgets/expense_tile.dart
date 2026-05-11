import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/currency_provider.dart';
import '../utils/constants.dart';
import '../utils/date_helpers.dart';

/// Reusable expense list tile.
class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;
  final VoidCallback? onDismissed;

  const ExpenseTile({
    super.key,
    required this.expense,
    this.onTap,
    this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final catColors = AppColors.categoryGradients[expense.category.index];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 4),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: borderColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: catColors),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(expense.category.icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${expense.category.label} · ${DateHelpers.relativeDate(expense.date)}',
                    style: TextStyle(color: subtitleColor, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              '- ${context.read<CurrencyProvider>().format(expense.amount)}',
              style: TextStyle(
                color: isDark ? AppColors.errorLight : AppColors.error,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
