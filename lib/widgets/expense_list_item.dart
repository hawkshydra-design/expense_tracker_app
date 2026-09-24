import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../models/income_category.dart';
import '../providers/currency_provider.dart';
import '../utils/constants.dart';
import '../utils/date_helpers.dart';

/// A dismissible expense list item with swipe-to-delete.
/// Extracted from HomeScreen for reusability.
class ExpenseListItem extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  const ExpenseListItem({
    super.key,
    required this.expense,
    required this.onTap,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.kTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.kTextSecondary : AppColors.lightTextSecondary;
    final cardColor = isDark ? AppColors.kSurface : AppColors.lightCard;

    // Use income category color for income items, expense category gradient for expenses
    final List<Color> iconGradient;
    final IconData iconData;
    if (expense.isIncome) {
      final incomeCat = expense.incomeCategory ?? IncomeCategory.other;
      iconGradient = [incomeCat.color, incomeCat.color.withValues(alpha: 0.7)];
      iconData = incomeCat.icon;
    } else {
      iconGradient = AppColors.categoryGradients[expense.category.index];
      iconData = expense.category.icon;
    }

    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        HapticFeedback.heavyImpact();
        onDismissed();
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.kRose.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: const Icon(LucideIcons.trash2, color: AppColors.kRose),
      ),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isDark ? AppColors.kCardBorder : AppColors.lightBorder.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: iconGradient),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(iconData,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      expense.displayCategory,
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${expense.isIncome ? '+' : '-'}${context.read<CurrencyProvider>().format(expense.amount)}',
                      style: TextStyle(
                        color: expense.isIncome ? AppColors.kGreen : AppColors.kRose,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      DateHelpers.relativeDate(expense.date),
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
