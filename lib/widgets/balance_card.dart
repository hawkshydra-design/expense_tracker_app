import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import '../utils/constants.dart';

/// Hero balance card for the dashboard.
/// Shows total balance with income/expense breakdown and count-up animation.
class BalanceCard extends StatelessWidget {
  final double totalBalance;
  final double totalIncome;
  final double totalExpenses;
  final double? trendAmount;

  const BalanceCard({
    super.key,
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpenses,
    this.trendAmount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isDark
            ? AppColors.balanceGradient
            : const LinearGradient(
                colors: [Color(0xFFC4885C), Color(0xFFD4956A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: ExpressiveShapes.heroCard,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.kPrimary.withValues(alpha: isDark ? 0.3 : 0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label
                Text(
                  'Total Balance',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Amount with count-up animation
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: totalBalance),
                        duration: AppDurations.countUp,
                        curve: Curves.easeOut,
                        builder: (context, value, _) {
                          return Text(
                            context.read<CurrencyProvider>().format(value),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    ),
                    if (trendAmount != null && trendAmount!.abs() > 0) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        flex: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: (trendAmount! >= 0
                                    ? AppColors.kGreen
                                    : AppColors.kRose)
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                trendAmount! >= 0
                                    ? LucideIcons.trendingUp
                                    : LucideIcons.trendingDown,
                                color: trendAmount! >= 0
                                    ? AppColors.kGreen
                                    : AppColors.kRose,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                context.read<CurrencyProvider>().format(trendAmount!.abs()),
                                style: TextStyle(
                                  color: trendAmount! >= 0
                                      ? AppColors.kGreen
                                      : AppColors.kRose,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                // Income / Expense row
                Row(
                  children: [
                    Expanded(
                      child: _IncomeExpenseChip(
                        icon: LucideIcons.arrowDownLeft,
                        label: 'Total Income',
                        amount: totalIncome,
                        color: AppColors.kGreen,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _IncomeExpenseChip(
                        icon: LucideIcons.arrowUpRight,
                        label: 'Total Expenses',
                        amount: totalExpenses,
                        color: AppColors.kRose,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IncomeExpenseChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color color;

  const _IncomeExpenseChip({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: amount),
                duration: AppDurations.countUp,
                curve: Curves.easeOut,
                builder: (context, value, _) {
                  return Text(
                    context.read<CurrencyProvider>().format(value),
                    style: TextStyle(
                      color: color,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
