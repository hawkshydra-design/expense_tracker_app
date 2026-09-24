import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import '../models/expense.dart';
import '../widgets/expandable_fab.dart';
import '../widgets/animated_bottom_nav_bar.dart';
import '../widgets/bounce_tap.dart';
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
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  /// Switch to a specific tab — callable from child widgets via
  /// `context.findAncestorStateOfType<HomeScreenState>()?.switchToTab(2)`
  void switchToTab(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppBreakpoints.isDesktop(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
      floatingActionButton: _currentIndex == 0 ? _buildFab() : null,
    );
  }

  // ─── Desktop: Side nav + content ─────────────────────────
  Widget _buildDesktopLayout() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.kSurface : AppColors.lightSurface;

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
                    ? AppColors.kCardBorder
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
                  LucideIcons.wallet,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              _buildDesktopNavItem(LucideIcons.home, 'Home', 0),
              const SizedBox(height: AppSpacing.sm),
              _buildDesktopNavItem(LucideIcons.barChart2, 'Stats', 1),
              const SizedBox(height: AppSpacing.sm),
              _buildDesktopNavItem(LucideIcons.settings2, 'Settings', 2),
              const Spacer(),
              // Theme toggle
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return BounceTap(
                    onTap: themeProvider.toggleTheme,
                    child: Icon(
                      themeProvider.isDark
                          ? LucideIcons.sun
                          : LucideIcons.moon,
                      color: isDark
                          ? AppColors.kTextMuted
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
                  icon: LucideIcons.home,
                  label: 'Home',
                ),
                NavItem(
                  icon: LucideIcons.barChart2,
                  label: 'Stats',
                ),
                NavItem(
                  icon: LucideIcons.settings2,
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
        ? AppColors.kViolet
        : (isDark ? AppColors.kTextMuted : AppColors.lightTextMuted);

    return Tooltip(
      message: label,
      child: BounceTap(
        onTap: () => setState(() => _currentIndex = index),
        child: AnimatedContainer(
          duration: AppDurations.fast,
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.kViolet.withValues(alpha: isDark ? 0.15 : 0.08)
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
          icon: LucideIcons.minusCircle,
          label: 'Add Expense',
          color: AppColors.kRose.withValues(alpha: 0.15),
          iconColor: AppColors.kRose,
          onPressed: () => context.push('/add-expense'),
        ),
        FabAction(
          icon: LucideIcons.plusCircle,
          label: 'Add Income',
          color: AppColors.kGreen.withValues(alpha: 0.15),
          iconColor: AppColors.kGreen,
          onPressed: () => context.push('/add-expense', extra: {
            'type': TransactionType.income,
          }),
        ),
      ],
    );
  }
}
