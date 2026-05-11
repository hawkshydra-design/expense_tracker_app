import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/currency_provider.dart';
import '../../utils/constants.dart';
import 'balance_card.dart';
import 'quick_action_row.dart';
import 'mini_summary_card.dart';
import 'expense_list_item.dart';
import 'pending_transaction_banner.dart';

/// The main dashboard tab content.
///
/// Displays the welcome header, balance card, quick actions,
/// summary cards (today/week/month), and the scrollable expense list.
/// Extracted from HomeScreen to keep it focused on navigation.
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final authProvider = context.watch<AuthProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();
    final padH = AppBreakpoints.horizontalPadding(context);

    // Dynamic bottom padding for floating nav bar on mobile
    final bottomPadding = AppBreakpoints.isMobile(context)
        ? MediaQuery.of(context).padding.bottom + 96
        : 40.0;

    return SafeArea(
      bottom: false, // We handle bottom padding manually for nav bar
      child: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          await expenseProvider.loadExpenses();
        },
        color: AppColors.primary,
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        child: CustomScrollView(
          slivers: [
            // ─── App Bar ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(padH, AppSpacing.lg, padH, 0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: AppBreakpoints.maxContentWidth(context),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: TextStyle(
                                    color: subtitleColor, fontSize: 14),
                              ),
                              Text(
                                authProvider.userName,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Center(
                            child: Text(
                              authProvider.userName.isNotEmpty
                                  ? authProvider.userName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
            ),

            // ─── Pending Transaction Banner ──────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(padH, AppSpacing.md, padH, 0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: AppBreakpoints.maxContentWidth(context),
                    ),
                    child: const PendingTransactionBanner(),
                  ),
                ),
              ),
            ),

            // ─── Balance Card ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(padH, AppSpacing.lg, padH, 0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: AppBreakpoints.maxContentWidth(context),
                    ),
                    child: BalanceCard(
                      totalBalance: expenseProvider.netBalance,
                      totalIncome: expenseProvider.totalIncome,
                      totalExpenses: expenseProvider.totalExpenses,
                      trendAmount: expenseProvider.monthTrend,
                    ),
                  ),
                ),
              ),
            ),

            // ─── Quick Actions ──────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(padH, AppSpacing.lg, padH, 0),
                child: QuickActionRow(
                  onAddExpense: () => context.push('/add-expense'),
                  onAddIncome: () => context.push('/add-expense'),
                ),
              ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
            ),

            // ─── Summary Row ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(padH, AppSpacing.lg, padH, 0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: AppBreakpoints.maxContentWidth(context),
                    ),
                    child: Row(
                      children: _buildSummaryCards(context, expenseProvider),
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 500.ms)
                  .slideY(begin: 0.15, delay: 400.ms),
            ),

            // ─── Transactions Header ───────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    padH, AppSpacing.lg, padH, AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transactions',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs + 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        '${expenseProvider.expenses.length} items',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
            ),

            // ─── Expense list ───────────────────────────────
            if (expenseProvider.expenses.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                        ),
                        child: Icon(
                          Icons.receipt_long_rounded,
                          color: AppColors.primary.withValues(alpha: 0.5),
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        AppStrings.noExpenses,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms, duration: 500.ms),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final expense = expenseProvider.expenses[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: padH),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: AppBreakpoints.maxContentWidth(context),
                          ),
                          child: ExpenseListItem(
                            expense: expense,
                            onTap: () =>
                                context.push('/add-expense', extra: expense),
                            onDismissed: () async {
                              final deleted = await expenseProvider
                                  .deleteExpense(expense.id);
                              if (context.mounted && deleted != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Deleted "${expense.title}"'),
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      textColor: AppColors.primary,
                                      onPressed: () => expenseProvider
                                          .restoreExpense(deleted),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(
                            delay: (600 + index * 60).ms, duration: 400.ms)
                        .slideX(
                            begin: 0.05, delay: (600 + index * 60).ms);
                  },
                  childCount: expenseProvider.expenses.length,
                  addAutomaticKeepAlives: false,
                ),
              ),

            // Dynamic bottom padding to prevent content hiding behind nav bar
            SliverToBoxAdapter(child: SizedBox(height: bottomPadding)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSummaryCards(
      BuildContext context, ExpenseProvider provider) {
    return [
      Expanded(
        child: GestureDetector(
          onTap: () => _showPeriodDetail(context, 'Today', provider.todaySpending, provider),
          child: MiniSummaryCard(
            label: 'Today',
            amount: provider.todaySpending,
            gradient: AppColors.successGradient,
            icon: Icons.today_rounded,
          ),
        ),
      ),
      const SizedBox(width: AppSpacing.sm),
      Expanded(
        child: GestureDetector(
          onTap: () => _showPeriodDetail(context, 'This Week', provider.weekSpending, provider),
          child: MiniSummaryCard(
            label: 'Week',
            amount: provider.weekSpending,
            gradient: AppColors.accentGradient,
            icon: Icons.date_range_rounded,
          ),
        ),
      ),
      const SizedBox(width: AppSpacing.sm),
      Expanded(
        child: GestureDetector(
          onTap: () => _showPeriodDetail(context, 'This Month', provider.monthSpending, provider),
          child: MiniSummaryCard(
            label: 'Month',
            amount: provider.monthSpending,
            gradient: AppColors.warmGradient,
            icon: Icons.calendar_month_rounded,
          ),
        ),
      ),
    ];
  }

  /// Show a bottom sheet with expenses for the selected period
  void _showPeriodDetail(
    BuildContext context,
    String period,
    double total,
    ExpenseProvider provider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyProvider = context.read<CurrencyProvider>();

    // Filter expenses by period
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    List<dynamic> filtered;

    switch (period) {
      case 'Today':
        filtered = provider.expenses
            .where((e) => e.date.isAfter(today.subtract(const Duration(seconds: 1))))
            .toList();
        break;
      case 'This Week':
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        filtered = provider.expenses
            .where((e) => e.date.isAfter(weekStart.subtract(const Duration(seconds: 1))))
            .toList();
        break;
      case 'This Month':
        final monthStart = DateTime(now.year, now.month, 1);
        filtered = provider.expenses
            .where((e) => e.date.isAfter(monthStart.subtract(const Duration(seconds: 1))))
            .toList();
        break;
      default:
        filtered = [];
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
        final textColor =
            isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        final subtitleColor =
            isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.65,
          ),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xxl),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          period,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs + 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.expenseGradient,
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            currencyProvider.format(total),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    'No expenses for this period',
                    style: TextStyle(color: subtitleColor, fontSize: 14),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(ctx).padding.bottom +
                            AppSpacing.lg),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final expense = filtered[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg, vertical: 2),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkBg
                                : AppColors.lightCardAlt,
                            borderRadius:
                                BorderRadius.circular(AppRadius.md),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: expense.category.color
                                      .withValues(alpha: 0.15),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Icon(expense.category.icon,
                                    color: expense.category.color,
                                    size: 18),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      expense.title,
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      expense.category.label,
                                      style: TextStyle(
                                        color: subtitleColor,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                currencyProvider.format(expense.amount),
                                style: TextStyle(
                                  color: AppColors.expense,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
