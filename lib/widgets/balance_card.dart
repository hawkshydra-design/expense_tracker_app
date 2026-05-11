import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import '../utils/constants.dart';

/// Hero balance card for the dashboard.
/// Shows total balance with income/expense breakdown.
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
            ? const LinearGradient(
                colors: [Color(0xFF1A1A3E), Color(0xFF2D1B69)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF4834DF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
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
                    color: Colors.white.withValues(alpha: 0.05),
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
                    color: Colors.white.withValues(alpha: 0.05),
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
                    // Amount
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            context.read<CurrencyProvider>().format(totalBalance),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                                        ? AppColors.income
                                        : AppColors.expense)
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    trendAmount! >= 0
                                        ? Icons.trending_up_rounded
                                        : Icons.trending_down_rounded,
                                    color: trendAmount! >= 0
                                        ? AppColors.income
                                        : AppColors.expense,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    context.read<CurrencyProvider>().format(trendAmount!.abs()),
                                    style: TextStyle(
                                      color: trendAmount! >= 0
                                          ? AppColors.income
                                          : AppColors.expense,
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
                            icon: Icons.arrow_downward_rounded,
                            label: 'Total Income',
                            amount: totalIncome,
                            color: AppColors.income,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _IncomeExpenseChip(
                            icon: Icons.arrow_upward_rounded,
                            label: 'Total Expenses',
                            amount: totalExpenses,
                            color: AppColors.expense,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1, delay: 200.ms);
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
              Text(
                context.read<CurrencyProvider>().format(amount),
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
