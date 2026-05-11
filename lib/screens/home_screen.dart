import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import '../widgets/expandable_fab.dart';
import '../widgets/animated_bottom_nav_bar.dart';
import '../widgets/dashboard_tab.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

/// Root screen — manages tab navigation and responsive layout.
///
/// Content for each tab lives in its own widget:
/// - [DashboardTab] — balance card, summary, expense list
/// - [StatsScreen] — analytics charts
/// - [SettingsScreen] — user preferences
///
/// This screen only handles navigation chrome (desktop rail / mobile floating nav)
/// and the expandable FAB.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppBreakpoints.isDesktop(context);

    return Scaffold(
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
      floatingActionButton: _currentIndex == 0 ? _buildFab() : null,
    );
  }

  // ─── Desktop: Side nav + content ─────────────────────────
  Widget _buildDesktopLayout() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Row(
      children: [
        // Side navigation rail
        Container(
          width: 80,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(
              right: BorderSide(
                color: isDark
                    ? AppColors.darkBorder.withValues(alpha: 0.3)
                    : AppColors.lightBorder,
              ),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl),
              // Logo
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              _buildDesktopNavItem(Icons.dashboard_rounded, 'Home', 0),
              const SizedBox(height: AppSpacing.sm),
              _buildDesktopNavItem(Icons.pie_chart_rounded, 'Stats', 1),
              const SizedBox(height: AppSpacing.sm),
              _buildDesktopNavItem(Icons.settings_rounded, 'Settings', 2),
              const Spacer(),
              // Theme toggle
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return IconButton(
                    onPressed: themeProvider.toggleTheme,
                    icon: Icon(
                      themeProvider.isDark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
        // Content
        Expanded(
          child: _buildContent(),
        ),
      ],
    );
  }

  // ─── Mobile: Floating bottom nav + content ────────────────
  Widget _buildMobileLayout() {
    return Stack(
      children: [
        // Content fills the entire screen
        _buildContent(),
        // Floating nav bar at the bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: RepaintBoundary(
            child: AnimatedBottomNavBar(
              items: const [
                NavItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard_rounded,
                  label: 'Home',
                ),
                NavItem(
                  icon: Icons.pie_chart_outline_rounded,
                  activeIcon: Icons.pie_chart_rounded,
                  label: 'Stats',
                ),
                NavItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings_rounded,
                  label: 'Settings',
                ),
              ],
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    // IndexedStack keeps all tabs alive — preserves scroll position
    // and avoids re-triggering entrance animations on tab switch
    return IndexedStack(
      index: _currentIndex,
      children: const [
        DashboardTab(),
        StatsScreen(),
        SettingsScreen(),
      ],
    );
  }

  Widget _buildDesktopNavItem(IconData icon, String label, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _currentIndex == index;
    final color = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted);

    return Tooltip(
      message: label,
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08)
                : null,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                    color: color, fontSize: 10, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFab() {
    return ExpandableFab(
      actions: [
        FabAction(
          icon: Icons.add_rounded,
          label: 'Add Expense',
          color: AppColors.expense.withValues(alpha: 0.15),
          iconColor: AppColors.expense,
          onPressed: () => context.push('/add-expense'),
        ),
        FabAction(
          icon: Icons.savings_rounded,
          label: 'Add Income',
          color: AppColors.income.withValues(alpha: 0.15),
          iconColor: AppColors.incomeDark,
          onPressed: () {
            // TODO: Navigate to add-income screen when implemented
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Income tracking coming soon!'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ],
    );
  }
}
