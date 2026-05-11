import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pending_transaction_provider.dart';
import '../../services/notification_bridge.dart';
import '../../di/service_locator.dart';
import '../../utils/constants.dart';
import 'settings_tile.dart';

/// Settings section for controlling smart UPI payment detection.
///
/// Android-only. Provides toggles for auto-detection and notification
/// access permission management. Shown conditionally in [SettingsScreen].
class SmartDetectionSection extends StatefulWidget {
  final Color cardColor;
  final Color borderColor;
  final bool isDark;
  final Color subtitleColor;

  const SmartDetectionSection({
    super.key,
    required this.cardColor,
    required this.borderColor,
    required this.isDark,
    required this.subtitleColor,
  });

  @override
  State<SmartDetectionSection> createState() => _SmartDetectionSectionState();
}

class _SmartDetectionSectionState extends State<SmartDetectionSection> {
  bool _isEnabled = false;
  bool _hasPermission = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final enabled = await NotificationBridge.isEnabled();
    bool permission = false;
    try {
      permission = await NotificationBridge.isPermissionGranted();
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isEnabled = enabled;
        _hasPermission = permission;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleAutoDetect(bool value) async {
    await NotificationBridge.setEnabled(value);
    setState(() => _isEnabled = value);

    if (value && !_hasPermission) {
      // Prompt to grant permission
      final granted = await NotificationBridge.requestPermission();
      if (granted) {
        setState(() => _hasPermission = true);
      }
      // Re-check after returning from settings
      await _loadState();
    }

    // Start/stop the notification bridge
    if (value) {
      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated && getIt.isRegistered<NotificationBridge>()) {
        final bridge = getIt<NotificationBridge>();
        if (!mounted) return;
        final pendingProvider = context.read<PendingTransactionProvider>();
        bridge.onTransactionDetected = (tx) {
          pendingProvider.addDetected(tx);
        };
        await bridge.startListening(authProvider.userId);
      }
    } else {
      if (getIt.isRegistered<NotificationBridge>()) {
        await getIt<NotificationBridge>().stopListening();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color:
              widget.borderColor.withValues(alpha: widget.isDark ? 0.3 : 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Smart Detection',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Auto-detect toggle
          SettingsTile(
            icon: Icons.radar_rounded,
            iconColor: AppColors.accent,
            title: 'Auto-Detect Payments',
            subtitle: _isEnabled ? 'Listening for UPI payments' : 'Off',
            trailing: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Switch.adaptive(
                    value: _isEnabled,
                    onChanged: _toggleAutoDetect,
                    activeTrackColor: AppColors.accent,
                  ),
          ),

          Divider(
            height: 1,
            indent: 56,
            color: widget.isDark
                ? AppColors.darkBorder.withValues(alpha: 0.3)
                : AppColors.lightBorder,
          ),

          // Notification access status
          InkWell(
            onTap: () async {
              final granted = await NotificationBridge.requestPermission();
              if (granted) {
                setState(() => _hasPermission = true);
              }
              await _loadState();
            },
            child: SettingsTile(
              icon: _hasPermission
                  ? Icons.verified_rounded
                  : Icons.warning_amber_rounded,
              iconColor: _hasPermission ? AppColors.success : AppColors.warning,
              title: 'Notification Access',
              subtitle: _hasPermission
                  ? 'Permission granted ✓'
                  : 'Tap to grant access',
              trailing: Icon(
                Icons.open_in_new_rounded,
                color: widget.subtitleColor,
                size: 18,
              ),
            ),
          ),

          // Info text
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm + 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: widget.isDark ? 0.06 : 0.04),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: widget.subtitleColor,
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Only payment notifications from UPI apps are processed. '
                      'No other notifications are read or stored.',
                      style: TextStyle(
                        color: widget.subtitleColor,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
