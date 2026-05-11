import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/currency_provider.dart';
import '../utils/constants.dart';
import '../widgets/settings/settings_tile.dart';
import '../widgets/settings/notification_settings_sheet.dart';
import '../widgets/settings/currency_picker_sheet.dart';
import '../widgets/settings/backup_export_sheet.dart';
import '../widgets/settings/smart_detection_section.dart';

/// Settings screen — orchestrates UI sections extracted into individual widgets.
///
/// Sections (each in its own file under `widgets/settings/`):
/// - [SettingsTile] — reusable row tile
/// - [NotificationSettingsSheet] — budget & reminder preferences
/// - [CurrencyPickerSheet] — multi-currency selector
/// - [BackupExportSheet] — CSV export & clipboard copy
/// - [SmartDetectionSection] — UPI auto-detection (Android only)
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  /// Whether the Smart Detection section should be shown
  static bool get _isAndroid => !kIsWeb && Platform.isAndroid;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final authProvider = context.watch<AuthProvider>();
    final currencyProvider = context.watch<CurrencyProvider>();
    final padH = AppBreakpoints.horizontalPadding(context);

    // Dynamic bottom padding for floating nav bar on mobile
    final bottomPadding = AppBreakpoints.isMobile(context)
        ? MediaQuery.of(context).padding.bottom + 96
        : 40.0;

    return SafeArea(
      bottom: false, // Handled manually for floating nav bar
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(padH, AppSpacing.lg, padH, 0),
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ).animate().fadeIn(duration: 400.ms),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

          // Profile section — tappable for account switching
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padH),
              child: _buildProfileCard(
                context,
                authProvider: authProvider,
                isDark: isDark,
                textColor: textColor,
                subtitleColor: subtitleColor,
              ),
            )
                .animate()
                .fadeIn(delay: 100.ms, duration: 400.ms)
                .slideY(begin: 0.1),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

          // Settings items
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padH),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(
                    color: borderColor.withValues(alpha: isDark ? 0.3 : 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    // Theme toggle
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, _) {
                        return SettingsTile(
                          icon: themeProvider.isDark
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          iconColor: AppColors.accentYellow,
                          title: 'Dark Mode',
                          subtitle: themeProvider.isDark ? 'On' : 'Off',
                          trailing: Switch.adaptive(
                            value: themeProvider.isDark,
                            onChanged: (_) => themeProvider.toggleTheme(),
                            activeTrackColor: AppColors.primary,
                          ),
                        );
                      },
                    ),
                    _divider(isDark),
                    // Notifications — FUNCTIONAL
                    InkWell(
                      onTap: () => _showNotificationSettings(context),
                      child: SettingsTile(
                        icon: Icons.notifications_outlined,
                        iconColor: AppColors.accent,
                        title: 'Notifications',
                        subtitle: 'Budget alerts & reminders',
                        trailing: Icon(Icons.chevron_right_rounded,
                            color: subtitleColor, size: 20),
                      ),
                    ),
                    _divider(isDark),
                    // Currency — FUNCTIONAL
                    InkWell(
                      onTap: () => _showCurrencyPicker(context),
                      child: SettingsTile(
                        icon: Icons.currency_exchange_rounded,
                        iconColor: AppColors.income,
                        title: 'Currency',
                        subtitle: '${currencyProvider.selected.code} (${currencyProvider.symbol})',
                        trailing: Icon(Icons.chevron_right_rounded,
                            color: subtitleColor, size: 20),
                      ),
                    ),
                    _divider(isDark),
                    // Backup — FUNCTIONAL
                    InkWell(
                      onTap: () => _showBackupOptions(context),
                      child: SettingsTile(
                        icon: Icons.backup_rounded,
                        iconColor: AppColors.gradientPurple,
                        title: 'Backup & Export',
                        subtitle: 'Export your expense data as CSV',
                        trailing: Icon(Icons.chevron_right_rounded,
                            color: subtitleColor, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .slideY(begin: 0.1),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

          // Smart Detection section (Android only)
          if (_isAndroid)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: padH),
                child: SmartDetectionSection(
                  cardColor: cardColor,
                  borderColor: borderColor,
                  isDark: isDark,
                  subtitleColor: subtitleColor,
                ),
              )
                  .animate()
                  .fadeIn(delay: 250.ms, duration: 400.ms)
                  .slideY(begin: 0.1),
            ),

          if (_isAndroid)
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

          // Danger zone
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padH),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(
                    color: borderColor.withValues(alpha: isDark ? 0.3 : 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => _showAboutDialog(context),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppRadius.xl),
                      ),
                      child: SettingsTile(
                        icon: Icons.info_outline_rounded,
                        iconColor: subtitleColor,
                        title: 'About',
                        subtitle: 'Version 2.0.0',
                        trailing: Icon(Icons.chevron_right_rounded,
                            color: subtitleColor, size: 20),
                      ),
                    ),
                    _divider(isDark),
                    InkWell(
                      onTap: () => _handleLogout(context),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(AppRadius.xl),
                      ),
                      child: const SettingsTile(
                        icon: Icons.logout_rounded,
                        iconColor: AppColors.error,
                        title: 'Log Out',
                        subtitle: 'Sign out of your account',
                        trailing: Icon(Icons.chevron_right_rounded,
                            color: AppColors.error, size: 20),
                        titleColor: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 400.ms)
                .slideY(begin: 0.1),
          ),

          SliverToBoxAdapter(child: SizedBox(height: bottomPadding)),
        ],
      ),
    );
  }

  // ─── Profile Card ───────────────────────────────────────────

  Widget _buildProfileCard(
    BuildContext context, {
    required AuthProvider authProvider,
    required bool isDark,
    required Color textColor,
    required Color subtitleColor,
  }) {
    return GestureDetector(
      onTap: () => _showAccountSwitcher(context),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.primaryDark.withValues(alpha: 0.1),
                  ],
                )
              : LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.06),
                    AppColors.primaryDark.withValues(alpha: 0.03),
                  ],
                ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: AppColors.primary
                .withValues(alpha: isDark ? 0.2 : 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Center(
                child: Text(
                  authProvider.userName.isNotEmpty
                      ? authProvider.userName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authProvider.userName,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    authProvider.userEmail,
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to switch account',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.swap_horiz_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(
      height: 1,
      indent: 56,
      color: isDark
          ? AppColors.darkBorder.withValues(alpha: 0.3)
          : AppColors.lightBorder,
    );
  }

  // ─── Sheet Launchers ────────────────────────────────────────

  void _showAccountSwitcher(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.read<AuthProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
        final textColor =
            isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        final subtitleColor =
            isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xxl),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Account',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Current account
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: isDark ? 0.1 : 0.06),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
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
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authProvider.userName,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            authProvider.userEmail,
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.income.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(
                          color: AppColors.income,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Switch account button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    // Log out current user and go to login
                    await authProvider.logout();
                    if (context.mounted) {
                      context.read<ExpenseProvider>().clear();
                      context.go('/login');
                    }
                  },
                  icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                  label: const Text('Log out & switch account'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'You can log in with a different email after signing out.',
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: MediaQuery.of(ctx).padding.bottom + AppSpacing.sm),
            ],
          ),
        );
      },
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const NotificationSettingsSheet(),
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const CurrencyPickerSheet(),
    );
  }

  void _showBackupOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const BackupExportSheet(),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            const Text('Expense Tracker'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 2.0.0',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'A beautiful personal expense tracker with charts, analytics, '
              'and smart UPI payment detection.',
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '© 2026 Expense Tracker',
              style: TextStyle(
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ─── Logout ─────────────────────────────────────────────────

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) {
        context.read<ExpenseProvider>().clear();
        // Use GoRouter instead of Navigator.pushAndRemoveUntil
        context.go('/login');
      }
    }
  }
}
