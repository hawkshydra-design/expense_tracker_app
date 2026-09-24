import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../screens/home_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/currency_provider.dart';
import '../../models/expense.dart';
import '../../utils/constants.dart';
import 'bounce_tap.dart';
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
class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.kTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.kTextSecondary : AppColors.lightTextSecondary;
    final authProvider = context.watch<AuthProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();
    final padH = AppBreakpoints.horizontalPadding(context);

    // Dynamic bottom padding for floating nav bar on mobile
    final bottomPadding = AppBreakpoints.isMobile(context)
        ? MediaQuery.of(context).padding.bottom + 96
        : 40.0;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          await expenseProvider.loadExpenses();
        },
        color: AppColors.kViolet,
        backgroundColor: isDark ? AppColors.kSurface : AppColors.lightCard,
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
                                style: TextStyle(color: subtitleColor, fontSize: 14),
                              ),
                              Text(
                                authProvider.userName,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              )
                                  .animate()
                                  .fadeIn(delay: 50.ms, duration: 400.ms)
                                  .slideX(begin: 0.3, curve: Curves.easeOutCubic),
                            ],
                          ),
                        ),
                        BounceTap(
                          onTap: () {
                            context.findAncestorStateOfType<HomeScreenState>()
                                ?.switchToTab(2);
                          },
                          child: Container(
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
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, curve: Curves.easeOut),
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
              )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 400.ms, curve: Curves.easeOut),
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
              )
                  .animate()
                  .fadeIn(delay: 150.ms, duration: 500.ms)
                  .scaleXY(begin: 0.95, curve: Curves.easeOutCubic),
            ),

            // ─── Quick Actions ──────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(padH, AppSpacing.lg, padH, 0),
                child: QuickActionRow(
                  onAddExpense: () => context.push('/add-expense'),
                  onAddIncome: () => context.push('/add-expense', extra: {
                    'type': TransactionType.income,
                  }),
                ),
              )
                  .animate()
                  .fadeIn(delay: 250.ms, duration: 400.ms, curve: Curves.easeOut),
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
                  .fadeIn(delay: 350.ms, duration: 400.ms, curve: Curves.easeOut)
                  .slideY(begin: 0.1, curve: Curves.easeOutCubic),
            ),

            // ─── Transactions Header ───────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(padH, AppSpacing.lg, padH, AppSpacing.sm),
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
                        color: AppColors.kViolet.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        '${expenseProvider.expenses.length} items',
                        style: const TextStyle(
                          color: AppColors.kViolet,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 450.ms, duration: 400.ms, curve: Curves.easeOut),
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
                          color: AppColors.kViolet.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                        ),
                        child: Icon(
                          LucideIcons.receipt,
                          color: AppColors.kViolet.withValues(alpha: 0.5),
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
                ),
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
                                      textColor: AppColors.kViolet,
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
                    );
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
            icon: LucideIcons.calendarCheck,
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
            icon: LucideIcons.calendarDays,
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
            icon: LucideIcons.calendar,
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
        final cardColor = isDark ? AppColors.kSurface : AppColors.lightCard;
        final textColor = isDark ? AppColors.kTextPrimary : AppColors.lightTextPrimary;
        final subtitleColor = isDark ? AppColors.kTextSecondary : AppColors.lightTextSecondary;

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
                        color: AppColors.kCardBorder,
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
                            borderRadius: BorderRadius.circular(AppRadius.full),
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
                                ? AppColors.kBackground
                                : AppColors.lightCardAlt,
                            borderRadius: BorderRadius.circular(AppRadius.md),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                '${expense.isIncome ? '+' : '-'}${currencyProvider.format(expense.amount)}',
                                style: TextStyle(
                                  color: expense.isIncome ? AppColors.kGreen : AppColors.kRose,
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
