import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/currency_provider.dart';
import '../../utils/constants.dart';

/// Bottom sheet for configuring notification preferences and budget limits.
///
/// Manages three toggle settings (daily reminder, budget alerts, weekly report)
/// and persists them via [SharedPreferences].
class NotificationSettingsSheet extends StatefulWidget {
  const NotificationSettingsSheet({super.key});

  @override
  State<NotificationSettingsSheet> createState() =>
      _NotificationSettingsSheetState();
}

class _NotificationSettingsSheetState extends State<NotificationSettingsSheet> {
  bool _dailyReminder = false;
  bool _budgetAlerts = false;
  bool _weeklyReport = false;
  double _budgetLimit = 10000;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyReminder = prefs.getBool('notif_daily_reminder') ?? false;
      _budgetAlerts = prefs.getBool('notif_budget_alerts') ?? false;
      _weeklyReport = prefs.getBool('notif_weekly_report') ?? false;
      _budgetLimit = prefs.getDouble('budget_limit') ?? 10000;
      final hour = prefs.getInt('reminder_hour') ?? 20;
      final minute = prefs.getInt('reminder_minute') ?? 0;
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_daily_reminder', _dailyReminder);
    await prefs.setBool('notif_budget_alerts', _budgetAlerts);
    await prefs.setBool('notif_weekly_report', _weeklyReport);
    await prefs.setDouble('budget_limit', _budgetLimit);
    await prefs.setInt('reminder_hour', _reminderTime.hour);
    await prefs.setInt('reminder_minute', _reminderTime.minute);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final currencySymbol = context.read<CurrencyProvider>().symbol;

    return Container(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg,
          MediaQuery.of(context).padding.bottom + AppSpacing.lg),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Notifications & Budget',
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Daily Reminder toggle
            _buildToggleRow(
              icon: Icons.alarm_rounded,
              iconColor: AppColors.accent,
              title: 'Daily Reminder',
              subtitle: _dailyReminder
                  ? 'Reminds you at ${_reminderTime.format(context)}'
                  : 'Get reminded to log expenses',
              value: _dailyReminder,
              onChanged: (v) {
                setState(() => _dailyReminder = v);
                _saveSettings();
              },
              isDark: isDark,
              textColor: textColor,
              subtitleColor: subtitleColor,
            ),

            // Reminder time picker (only visible when daily reminder is on)
            if (_dailyReminder)
              Padding(
                padding: const EdgeInsets.only(left: 52, bottom: AppSpacing.md),
                child: GestureDetector(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _reminderTime,
                    );
                    if (picked != null) {
                      setState(() => _reminderTime = picked);
                      _saveSettings();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: isDark ? 0.1 : 0.06),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule_rounded,
                            color: AppColors.accent, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Time: ${_reminderTime.format(context)}',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.edit_rounded,
                            color: AppColors.accent, size: 14),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: AppSpacing.sm),

            // Budget Alerts toggle
            _buildToggleRow(
              icon: Icons.account_balance_wallet_rounded,
              iconColor: AppColors.warning,
              title: 'Budget Alerts',
              subtitle: _budgetAlerts
                  ? 'Alert when spending exceeds $currencySymbol${_budgetLimit.toStringAsFixed(0)}/month'
                  : 'Get alerted when over budget',
              value: _budgetAlerts,
              onChanged: (v) {
                setState(() => _budgetAlerts = v);
                _saveSettings();
              },
              isDark: isDark,
              textColor: textColor,
              subtitleColor: subtitleColor,
            ),

            // Budget limit slider (only visible when budget alerts are on)
            if (_budgetAlerts)
              Padding(
                padding: const EdgeInsets.only(left: 40, right: 8, bottom: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly budget: $currencySymbol${_budgetLimit.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Slider(
                      value: _budgetLimit,
                      min: 1000,
                      max: 100000,
                      divisions: 99,
                      activeColor: AppColors.warning,
                      label: '$currencySymbol${_budgetLimit.toStringAsFixed(0)}',
                      onChanged: (v) {
                        setState(() => _budgetLimit = v);
                      },
                      onChangeEnd: (_) => _saveSettings(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${currencySymbol}1,000', style: TextStyle(color: subtitleColor, fontSize: 10)),
                        Text('${currencySymbol}100,000', style: TextStyle(color: subtitleColor, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: AppSpacing.sm),

            // Weekly Report toggle
            _buildToggleRow(
              icon: Icons.summarize_rounded,
              iconColor: AppColors.primary,
              title: 'Weekly Summary',
              subtitle: 'Get a spending summary every Sunday',
              value: _weeklyReport,
              onChanged: (v) {
                setState(() => _weeklyReport = v);
                _saveSettings();
              },
              isDark: isDark,
              textColor: textColor,
              subtitleColor: subtitleColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
    required Color textColor,
    required Color subtitleColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: TextStyle(color: subtitleColor, fontSize: 12)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: iconColor,
          ),
        ],
      ),
    );
  }
}
