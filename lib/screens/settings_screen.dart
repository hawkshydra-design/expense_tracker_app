import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
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
import '../widgets/bounce_tap.dart';

/// Settings screen — uses flutter_animate for staggered mount animations.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static bool get _isAndroid => !kIsWeb && Platform.isAndroid;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.kTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.kTextSecondary : AppColors.lightTextSecondary;
    final cardColor = isDark ? AppColors.kSurface : AppColors.lightCard;
    final borderColor = isDark ? AppColors.kCardBorder : AppColors.lightBorder;
    final authProvider = context.watch<AuthProvider>();
    final currencyProvider = context.watch<CurrencyProvider>();
    final padH = AppBreakpoints.horizontalPadding(context);

    final bottomPadding = AppBreakpoints.isMobile(context)
        ? MediaQuery.of(context).padding.bottom + 96
        : 40.0;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          // ── Header ──
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(padH, AppSpacing.lg, padH, 0),
              child: Text(
                'Settings',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: textColor),
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, curve: Curves.easeOut),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

          // ── Profile card ──
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
                .fadeIn(delay: 100.ms, duration: 400.ms, curve: Curves.easeOut)
                .slideY(begin: 0.08, curve: Curves.easeOutCubic),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

          // ── Settings section ──
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padH),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: borderColor.withValues(alpha: isDark ? 0.3 : 0.5)),
                ),
                child: Column(
                  children: [
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, _) {
                        return SettingsTile(
                          icon: themeProvider.isDark ? LucideIcons.moon : LucideIcons.sun,
                          iconColor: AppColors.kAmber,
                          title: 'Dark Mode',
                          subtitle: themeProvider.isDark ? 'On' : 'Off',
                          trailing: Switch.adaptive(
                            value: themeProvider.isDark,
                            onChanged: (_) => themeProvider.toggleTheme(),
                            activeTrackColor: AppColors.kViolet,
                          ),
                        );
                      },
                    ),
                    _divider(isDark),
                    BounceTap(
                      onTap: () => _showNotificationSettings(context),
                      child: SettingsTile(
                        icon: LucideIcons.bell,
                        iconColor: AppColors.kCyan,
                        title: 'Notifications',
                        subtitle: 'Budget alerts & reminders',
                        trailing: Icon(LucideIcons.chevronRight, color: subtitleColor, size: 20),
                      ),
                    ),
                    _divider(isDark),
                    BounceTap(
                      onTap: () => _showCurrencyPicker(context),
                      child: SettingsTile(
                        icon: LucideIcons.coins,
                        iconColor: AppColors.kGreen,
                        title: 'Currency',
                        subtitle: '${currencyProvider.selected.code} (${currencyProvider.symbol})',
                        trailing: Icon(LucideIcons.chevronRight, color: subtitleColor, size: 20),
                      ),
                    ),
                    _divider(isDark),
                    BounceTap(
                      onTap: () => _showBackupOptions(context),
                      child: SettingsTile(
                        icon: LucideIcons.uploadCloud,
                        iconColor: AppColors.kViolet,
                        title: 'Backup & Export',
                        subtitle: 'Export your expense data as CSV',
                        trailing: Icon(LucideIcons.chevronRight, color: subtitleColor, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms, curve: Curves.easeOut)
                .slideY(begin: 0.08, curve: Curves.easeOutCubic),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

          // ── Smart Detection (Android) ──
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
                  .fadeIn(delay: 280.ms, duration: 400.ms)
                  .slideY(begin: 0.08, curve: Curves.easeOutCubic),
            ),

          if (_isAndroid)
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

          // ── Danger zone ──
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padH),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: borderColor.withValues(alpha: isDark ? 0.3 : 0.5)),
                ),
                child: Column(
                  children: [
                    BounceTap(
                      onTap: () => _showAboutDialog(context),
                      child: SettingsTile(
                        icon: LucideIcons.info,
                        iconColor: subtitleColor,
                        title: 'About',
                        subtitle: 'Version 2.2.0',
                        trailing: Icon(LucideIcons.chevronRight, color: subtitleColor, size: 20),
                      ),
                    ),
                    _divider(isDark),
                    BounceTap(
                      onTap: () => _handleLogout(context),
                      child: SettingsTile(
                        icon: LucideIcons.logOut,
                        iconColor: AppColors.kPink,
                        title: 'Log Out',
                        subtitle: 'Sign out of your account',
                        trailing: const Icon(LucideIcons.chevronRight, color: AppColors.kPink, size: 20),
                        titleColor: AppColors.kPink,
                      ),
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 350.ms, duration: 400.ms, curve: Curves.easeOut)
                .slideY(begin: 0.08, curve: Curves.easeOutCubic),
          ),

          SliverToBoxAdapter(child: SizedBox(height: bottomPadding)),
        ],
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context, {
    required AuthProvider authProvider,
    required bool isDark,
    required Color textColor,
    required Color subtitleColor,
  }) {
    return BounceTap(
      onTap: () => _showAccountSwitcher(context),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(colors: [
                  AppColors.kViolet.withValues(alpha: 0.15),
                  AppColors.kViolet.withValues(alpha: 0.05),
                ])
              : LinearGradient(colors: [
                  AppColors.kViolet.withValues(alpha: 0.06),
                  AppColors.kViolet.withValues(alpha: 0.02),
                ]),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.kViolet.withValues(alpha: isDark ? 0.2 : 0.1)),
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
                  authProvider.userName.isNotEmpty ? authProvider.userName[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(authProvider.userName,
                      style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 17)),
                  const SizedBox(height: 2),
                  Text(authProvider.userEmail,
                      style: TextStyle(color: subtitleColor, fontSize: 13)),
                  const SizedBox(height: 4),
                  const Text('Tap to switch account',
                      style: TextStyle(color: AppColors.kViolet, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Icon(LucideIcons.arrowLeftRight, color: AppColors.kViolet, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(
      height: 1,
      indent: 56,
      color: isDark ? AppColors.kCardBorder : AppColors.lightBorder,
    );
  }

  void _showAccountSwitcher(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.read<AuthProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final cardColor = isDark ? AppColors.kSurface : AppColors.lightCard;
        final textColor = isDark ? AppColors.kTextPrimary : AppColors.lightTextPrimary;
        final subtitleColor = isDark ? AppColors.kTextSecondary : AppColors.lightTextSecondary;

        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.kCardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Account', style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.kViolet.withValues(alpha: isDark ? 0.1 : 0.06),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.kViolet.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Center(
                        child: Text(
                          authProvider.userName.isNotEmpty ? authProvider.userName[0].toUpperCase() : 'U',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(authProvider.userName,
                              style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 15)),
                          Text(authProvider.userEmail,
                              style: TextStyle(color: subtitleColor, fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.kGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Text('Active',
                          style: TextStyle(color: AppColors.kGreen, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await authProvider.logout();
                    if (context.mounted) {
                      context.read<ExpenseProvider>().clear();
                      context.go('/login');
                    }
                  },
                  icon: const Icon(LucideIcons.arrowLeftRight, size: 18),
                  label: const Text('Log out & switch account'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('You can log in with a different email after signing out.',
                  style: TextStyle(color: subtitleColor, fontSize: 11), textAlign: TextAlign.center),
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
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(LucideIcons.wallet, color: Colors.white, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            const Text('Expense Tracker'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 2.2.0',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.kTextPrimary : AppColors.lightTextPrimary,
                )),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'A beautiful personal expense tracker with charts, analytics, '
              'and smart UPI payment detection.',
              style: TextStyle(
                color: isDark ? AppColors.kTextSecondary : AppColors.lightTextSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('© 2026 Expense Tracker',
                style: TextStyle(
                  color: isDark ? AppColors.kTextMuted : AppColors.lightTextMuted,
                  fontSize: 12,
                )),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.kPink),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) {
        context.read<ExpenseProvider>().clear();
        context.go('/login');
      }
    }
  }
}
