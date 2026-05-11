import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../providers/currency_provider.dart';
import '../models/category.dart';
import '../utils/constants.dart';
import '../widgets/donut_chart_widget.dart';
import '../widgets/line_chart_widget.dart';
import '../widgets/category_grid_card.dart';
import '../widgets/glass_card.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedRange = '6M';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // Only rebuild on discrete tab index changes, not animation frames
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Returns the number of months to display based on selected range
  int get _rangeMonths => switch (_selectedRange) {
        '7D' => 1,
        '1M' => 1,
        '3M' => 3,
        '6M' => 6,
        '1Y' => 12,
        _ => 6,
      };

  /// Returns the date range start based on selected range
  DateTime get _rangeStart {
    final now = DateTime.now();
    return switch (_selectedRange) {
      '7D' => now.subtract(const Duration(days: 7)),
      '1M' => DateTime(now.year, now.month - 1, now.day),
      '3M' => DateTime(now.year, now.month - 3, 1),
      '6M' => DateTime(now.year, now.month - 6, 1),
      '1Y' => DateTime(now.year - 1, now.month, 1),
      _ => DateTime(now.year, now.month - 6, 1),
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final expenseProvider = context.watch<ExpenseProvider>();
    final categoryData = expenseProvider.spendingByCategory;
    final padH = AppBreakpoints.horizontalPadding(context);

    // Dynamic bottom padding for floating nav bar on mobile
    final bottomPadding = AppBreakpoints.isMobile(context)
        ? MediaQuery.of(context).padding.bottom + 96
        : 40.0;

    return SafeArea(
      bottom: false, // Handled manually for floating nav bar
      child: CustomScrollView(
        slivers: [
          // ─── Header ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(padH, AppSpacing.lg, padH, 0),
              child: Row(
                children: [
                  Text(
                    'Statistics',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),
          ),

          // ─── Tab Bar ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(padH, AppSpacing.lg, padH, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCardAlt,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: subtitleColor,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerHeight: 0,
                  indicator: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  splashFactory: NoSplash.splashFactory,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(text: 'Categories'),
                    Tab(text: 'Monthly Spending'),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
          ),

          // ─── Tab Content ────────────────────────────────
          if (_tabController.index == 0)
            ..._buildCategoriesTab(
                categoryData, isDark, textColor, subtitleColor, padH)
          else
            ..._buildMonthlyTab(
                expenseProvider, isDark, textColor, subtitleColor, padH),

          SliverToBoxAdapter(child: SizedBox(height: bottomPadding)),
        ],
      ),
    );
  }

  // ─── Categories Tab ─────────────────────────────────────
  List<Widget> _buildCategoriesTab(
    Map<ExpenseCategory, double> categoryData,
    bool isDark,
    Color textColor,
    Color subtitleColor,
    double padH,
  ) {
    final now = DateTime.now();
    final monthLabel = DateFormat('MMMM yyyy').format(now);
    final columns = AppBreakpoints.gridColumns(context);

    return [
      // Donut chart
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(padH, AppSpacing.lg, padH, 0),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: AppBreakpoints.maxContentWidth(context),
              ),
              child: GlassCard(
                child: DonutChartWidget(
                  data: categoryData,
                  centerLabel: monthLabel,
                ),
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 500.ms)
            .scale(begin: const Offset(0.95, 0.95), delay: 200.ms),
      ),

      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

      // Category grid
      if (categoryData.isNotEmpty)
        _buildCategoryGrid(categoryData, columns, padH),
    ];
  }

  // ─── Category Grid (pre-computed for O(n) instead of O(n²)) ──
  Widget _buildCategoryGrid(
    Map<ExpenseCategory, double> categoryData,
    int columns,
    double padH,
  ) {
    // Pre-compute once — avoids .toList() per item in the builder
    final entries = categoryData.entries.toList();
    final total = categoryData.values.fold(0.0, (s, v) => s + v);
    final expenses = context.read<ExpenseProvider>().expenses;

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: padH),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.1,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final entry = entries[index];
            final pct = total > 0 ? entry.value / total * 100 : 0.0;
            final txCount =
                expenses.where((e) => e.category == entry.key).length;
            return CategoryGridCard(
              category: entry.key,
              amount: entry.value,
              transactionCount: txCount,
              percentage: pct,
            )
                .animate()
                .fadeIn(delay: (350 + index * 80).ms, duration: 400.ms)
                .scale(
                    begin: const Offset(0.9, 0.9),
                    delay: (350 + index * 80).ms);
          },
          childCount: entries.length,
        ),
      ),
    );
  }

  // ─── Monthly Spending Tab ───────────────────────────────
  List<Widget> _buildMonthlyTab(
    ExpenseProvider provider,
    bool isDark,
    Color textColor,
    Color subtitleColor,
    double padH,
  ) {
    // Use the selected range to compute data
    final monthlyData = _getMonthlySpendingData(provider);
    final rangeStart = _rangeStart;
    final now = DateTime.now();
    final currentMonth = DateFormat('MMM').format(now);

    // Compute real statistics for the selected range
    final rangeTotal = provider.getSpendingInRange(rangeStart, now);
    final monthCount = _rangeMonths.clamp(1, 12);
    final avgMonthly = rangeTotal / monthCount;

    // Real month-over-month trend
    final trend = provider.monthTrend;
    final trendIsUp = trend > 0;
    final trendAbs = trend.abs();

    return [
      // Total amount
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(padH, AppSpacing.lg, padH, 0),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: AppBreakpoints.maxContentWidth(context),
              ),
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Avg. monthly expenses ($_selectedRange)',
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      context.read<CurrencyProvider>().format(avgMonthly),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (trendAbs > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: (trendIsUp
                                    ? AppColors.expense
                                    : AppColors.income)
                                .withValues(alpha: 0.15),
                            borderRadius:
                                BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                trendIsUp
                                    ? Icons.trending_up_rounded
                                    : Icons.trending_down_rounded,
                                color: trendIsUp
                                    ? AppColors.expense
                                    : AppColors.income,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '${context.read<CurrencyProvider>().format(trendAbs)} vs last month',
                                  style: TextStyle(
                                    color: trendIsUp
                                        ? AppColors.expense
                                        : AppColors.income,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    // Legend
                    Row(
                      children: [
                        _legendDot(AppColors.expense, 'Expense'),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Line chart — now uses range-filtered data
                    LineChartWidget(
                      monthlyData: monthlyData,
                      highlightMonth: currentMonth,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Time range filters — NOW FUNCTIONAL
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: ['7D', '1M', '3M', '6M', '1Y']
                            .map((range) => _buildRangeChip(
                                range, isDark, subtitleColor))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
      ),

      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

      // Insight cards — real data
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padH),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: AppBreakpoints.maxContentWidth(context),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _InsightCard(
                      icon: Icons.trending_up_rounded,
                      title: 'Current month spending',
                      subtitle: context.read<CurrencyProvider>().format(
                          provider.monthSpending),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _InsightCard(
                      icon: Icons.savings_rounded,
                      title: 'Previous month',
                      subtitle: context.read<CurrencyProvider>().format(
                          provider.previousMonthSpending),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(delay: 400.ms, duration: 400.ms)
            .slideY(begin: 0.1, delay: 400.ms),
      ),
    ];
  }

  Widget _legendDot(Color color, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildRangeChip(String range, bool isDark, Color subtitleColor) {
    final isSelected = _selectedRange == range;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () => setState(() => _selectedRange = range),
        child: AnimatedContainer(
          duration: AppDurations.fast,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.darkCardAlt : AppColors.lightCardAlt),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Text(
            range,
            style: TextStyle(
              color: isSelected ? Colors.white : subtitleColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  /// Generates monthly spending data filtered by the selected range
  Map<String, double> _getMonthlySpendingData(ExpenseProvider provider) {
    final now = DateTime.now();
    final months = _rangeMonths;
    final data = <String, double>{};

    for (int i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final label = DateFormat('MMM').format(month);
      final expenses = provider.getExpensesForMonth(month.year, month.month);
      data[label] = expenses.fold(0.0, (s, e) => s + e.amount);
    }
    return data;
  }
}

// ─── Insight Card ───────────────────────────────────────────
class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;

  const _InsightCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: borderColor.withValues(alpha: isDark ? 0.3 : 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color:
                  AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
