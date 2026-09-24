import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../providers/currency_provider.dart';
import '../models/category.dart';
import '../models/income_category.dart';
import '../utils/constants.dart';
import '../widgets/donut_chart_widget.dart';
import '../widgets/category_grid_card.dart';
import '../widgets/glass_card.dart';
import '../widgets/stats/spending_bar_chart.dart';
import '../widgets/stats/period_summary_chips.dart';
import '../widgets/stats/income_category_grid_card.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with TickerProviderStateMixin {
  /// 0 = Expense, 1 = Income
  late final PageController _pageController;
  int _selectedTypeIndex = 0;

  /// 0 = Daily, 1 = Weekly, 2 = Monthly
  int _selectedPeriod = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _switchType(int index) {
    HapticFeedback.selectionClick();
    setState(() => _selectedTypeIndex = index);
    _pageController.animateToPage(
      index,
      duration: AppDurations.normal,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.kTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor =
        isDark ? AppColors.kTextSecondary : AppColors.lightTextSecondary;
    final padH = AppBreakpoints.horizontalPadding(context);
    final bottomPadding = AppBreakpoints.isMobile(context)
        ? MediaQuery.of(context).padding.bottom + 96
        : 40.0;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          // ─── Header ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(padH, AppSpacing.lg, padH, 0),
              child: Text(
                'Statistics',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, curve: Curves.easeOut),
          ),

          // ─── Expense / Income Toggle ────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(padH, AppSpacing.lg, padH, 0),
              child: _buildTypeToggle(isDark, subtitleColor),
            )
                .animate()
                .fadeIn(delay: 100.ms, duration: 400.ms, curve: Curves.easeOut),
          ),

          // ─── Content ────────────────────────────────────
          SliverFillRemaining(
            hasScrollBody: true,
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                HapticFeedback.selectionClick();
                setState(() => _selectedTypeIndex = index);
              },
              children: [
                _ExpenseStatsView(
                  selectedPeriod: _selectedPeriod,
                  onPeriodChanged: (p) => setState(() => _selectedPeriod = p),
                  bottomPadding: bottomPadding,
                ),
                _IncomeStatsView(
                  selectedPeriod: _selectedPeriod,
                  onPeriodChanged: (p) => setState(() => _selectedPeriod = p),
                  bottomPadding: bottomPadding,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeToggle(bool isDark, Color subtitleColor) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.kSurface : AppColors.lightCardAlt,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark
              ? AppColors.kCardBorder.withValues(alpha: 0.3)
              : AppColors.lightBorder.withValues(alpha: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              label: 'Expenses',
              icon: LucideIcons.arrowUpRight,
              isSelected: _selectedTypeIndex == 0,
              color: AppColors.kRose,
              onTap: () => _switchType(0),
            ),
          ),
          Expanded(
            child: _ToggleButton(
              label: 'Income',
              icon: LucideIcons.arrowDownLeft,
              isSelected: _selectedTypeIndex == 1,
              color: AppColors.kGreen,
              onTap: () => _switchType(1),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Expense Stats View
// ═══════════════════════════════════════════════════════════════

class _ExpenseStatsView extends StatelessWidget {
  final int selectedPeriod;
  final ValueChanged<int> onPeriodChanged;
  final double bottomPadding;

  const _ExpenseStatsView({
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.kTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor =
        isDark ? AppColors.kTextSecondary : AppColors.lightTextSecondary;
    final provider = context.watch<ExpenseProvider>();
    final currencyProvider = context.read<CurrencyProvider>();
    final padH = AppBreakpoints.horizontalPadding(context);
    final columns = AppBreakpoints.gridColumns(context);

    final categoryData = provider.spendingByCategory;
    final barData = switch (selectedPeriod) {
      0 => provider.dailySpendingData,
      1 => provider.weeklySpendingData,
      _ => provider.monthlySpendingData,
    };

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: padH),
      children: [
        const SizedBox(height: AppSpacing.lg),

        // Period summary chips
        PeriodSummaryChips(
          todayAmount: provider.todaySpending,
          weekAmount: provider.weekSpending,
          monthAmount: provider.monthSpending,
          accentColor: AppColors.kRose,
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 400.ms)
            .slideY(begin: 0.08, curve: Curves.easeOutCubic),

        const SizedBox(height: AppSpacing.lg),

        // Period selector (Daily / Weekly / Monthly)
        _PeriodSelector(
          selectedIndex: selectedPeriod,
          onChanged: onPeriodChanged,
          color: AppColors.kRose,
        )
            .animate()
            .fadeIn(delay: 250.ms, duration: 400.ms),

        const SizedBox(height: AppSpacing.lg),

        // Bar chart
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                switch (selectedPeriod) {
                  0 => 'Daily Spending (Last 7 Days)',
                  1 => 'Weekly Spending (Last 4 Weeks)',
                  _ => 'Monthly Spending (Last 6 Months)',
                },
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SpendingBarChart(
                data: barData,
                barColor: AppColors.kRose,
                currencySymbol: currencyProvider.symbol,
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 300.ms, duration: 400.ms)
            .slideY(begin: 0.08, curve: Curves.easeOutCubic),

        const SizedBox(height: AppSpacing.lg),

        // Donut chart
        if (categoryData.isNotEmpty) ...[
          GlassCard(
            child: DonutChartWidget(
              data: categoryData,
              centerLabel: 'Expenses',
            ),
          )
              .animate()
              .fadeIn(delay: 350.ms, duration: 400.ms)
              .slideY(begin: 0.08, curve: Curves.easeOutCubic),

          const SizedBox(height: AppSpacing.lg),

          // Category grid
          _buildCategoryGrid(categoryData, columns, provider),
        ],

        if (categoryData.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
            child: Center(
              child: Column(
                children: [
                  Icon(LucideIcons.barChart2,
                      color: subtitleColor.withValues(alpha: 0.4), size: 48),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No expense data yet',
                    style: TextStyle(color: subtitleColor, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add expenses to see your statistics',
                    style: TextStyle(
                        color: subtitleColor.withValues(alpha: 0.6),
                        fontSize: 13),
                  ),
                ],
              ),
            ),
          ),

        SizedBox(height: bottomPadding),
      ],
    );
  }

  Widget _buildCategoryGrid(
    Map<ExpenseCategory, double> categoryData,
    int columns,
    ExpenseProvider provider,
  ) {
    final entries = categoryData.entries.toList();
    final total = categoryData.values.fold(0.0, (s, v) => s + v);
    final expenses = provider.onlyExpenses;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.85,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final count =
            expenses.where((e) => e.category == entry.key).length;
        return CategoryGridCard(
          category: entry.key,
          amount: entry.value,
          total: total,
          transactionCount: count,
        )
            .animate()
            .fadeIn(
                delay: (400 + index * 60).ms,
                duration: 400.ms,
                curve: Curves.easeOut)
            .slideY(begin: 0.1, curve: Curves.easeOutCubic);
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Income Stats View
// ═══════════════════════════════════════════════════════════════

class _IncomeStatsView extends StatelessWidget {
  final int selectedPeriod;
  final ValueChanged<int> onPeriodChanged;
  final double bottomPadding;

  const _IncomeStatsView({
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.kTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor =
        isDark ? AppColors.kTextSecondary : AppColors.lightTextSecondary;
    final provider = context.watch<ExpenseProvider>();
    final currencyProvider = context.read<CurrencyProvider>();
    final padH = AppBreakpoints.horizontalPadding(context);
    final columns = AppBreakpoints.gridColumns(context);

    final incomeCatData = provider.incomeByCategory;
    final barData = switch (selectedPeriod) {
      0 => provider.dailyIncomeData,
      1 => provider.weeklyIncomeData,
      _ => provider.monthlyIncomeData,
    };

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: padH),
      children: [
        const SizedBox(height: AppSpacing.lg),

        // Period summary chips
        PeriodSummaryChips(
          todayAmount: provider.todayIncome,
          weekAmount: provider.weekIncome,
          monthAmount: provider.monthIncome,
          accentColor: AppColors.kGreen,
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 400.ms)
            .slideY(begin: 0.08, curve: Curves.easeOutCubic),

        const SizedBox(height: AppSpacing.lg),

        // Period selector
        _PeriodSelector(
          selectedIndex: selectedPeriod,
          onChanged: onPeriodChanged,
          color: AppColors.kGreen,
        )
            .animate()
            .fadeIn(delay: 250.ms, duration: 400.ms),

        const SizedBox(height: AppSpacing.lg),

        // Bar chart
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                switch (selectedPeriod) {
                  0 => 'Daily Income (Last 7 Days)',
                  1 => 'Weekly Income (Last 4 Weeks)',
                  _ => 'Monthly Income (Last 6 Months)',
                },
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SpendingBarChart(
                data: barData,
                barColor: AppColors.kGreen,
                currencySymbol: currencyProvider.symbol,
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 300.ms, duration: 400.ms)
            .slideY(begin: 0.08, curve: Curves.easeOutCubic),

        const SizedBox(height: AppSpacing.lg),

        // Income category grid
        if (incomeCatData.isNotEmpty) ...[
          _buildIncomeCategoryGrid(incomeCatData, columns, provider),
        ],

        if (incomeCatData.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
            child: Center(
              child: Column(
                children: [
                  Icon(LucideIcons.trendingUp,
                      color: subtitleColor.withValues(alpha: 0.4), size: 48),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No income data yet',
                    style: TextStyle(color: subtitleColor, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add income to see your earnings breakdown',
                    style: TextStyle(
                        color: subtitleColor.withValues(alpha: 0.6),
                        fontSize: 13),
                  ),
                ],
              ),
            ),
          ),

        SizedBox(height: bottomPadding),
      ],
    );
  }

  Widget _buildIncomeCategoryGrid(
    Map<IncomeCategory, double> incomeCatData,
    int columns,
    ExpenseProvider provider,
  ) {
    final entries = incomeCatData.entries.toList();
    final total = incomeCatData.values.fold(0.0, (s, v) => s + v);
    final incomes = provider.onlyIncome;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.85,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final count = incomes
            .where((e) =>
                (e.incomeCategory ?? IncomeCategory.other) == entry.key)
            .length;
        return IncomeCategoryGridCard(
          category: entry.key,
          amount: entry.value,
          total: total,
          transactionCount: count,
        )
            .animate()
            .fadeIn(
                delay: (400 + index * 60).ms,
                duration: 400.ms,
                curve: Curves.easeOut)
            .slideY(begin: 0.1, curve: Curves.easeOutCubic);
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Shared Widgets
// ═══════════════════════════════════════════════════════════════

class _ToggleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.4) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 20,
                color: isSelected
                    ? color
                    : (isDark
                        ? AppColors.kTextMuted
                        : AppColors.lightTextMuted)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? color
                    : (isDark
                        ? AppColors.kTextMuted
                        : AppColors.lightTextMuted),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Color color;

  const _PeriodSelector({
    required this.selectedIndex,
    required this.onChanged,
    required this.color,
  });

  static const _labels = ['Daily', 'Weekly', 'Monthly'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor =
        isDark ? AppColors.kTextSecondary : AppColors.lightTextSecondary;

    return Row(
      children: List.generate(_labels.length, (index) {
        final isSelected = selectedIndex == index;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(index);
            },
            child: AnimatedContainer(
              duration: AppDurations.fast,
              padding: const EdgeInsets.symmetric(vertical: 10),
              margin: EdgeInsets.only(
                right: index < _labels.length - 1 ? AppSpacing.sm : 0,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: isDark ? 0.15 : 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: isSelected
                      ? color.withValues(alpha: 0.3)
                      : (isDark
                          ? AppColors.kCardBorder.withValues(alpha: 0.3)
                          : AppColors.lightBorder.withValues(alpha: 0.5)),
                ),
              ),
              child: Center(
                child: Text(
                  _labels[index],
                  style: TextStyle(
                    color: isSelected ? color : subtitleColor,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
