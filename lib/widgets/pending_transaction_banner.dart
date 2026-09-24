import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/pending_transaction_provider.dart';
import '../utils/constants.dart';
import 'bounce_tap.dart';

/// Dashboard banner showing count of auto-detected pending payments.
///
/// Displays a gradient card with pending count, top 2 preview items,
/// and a "Review" button. Hidden on non-Android platforms or when
/// no pending transactions exist.
class PendingTransactionBanner extends StatefulWidget {
  const PendingTransactionBanner({super.key});

  @override
  State<PendingTransactionBanner> createState() => _PendingTransactionBannerState();
}

class _PendingTransactionBannerState extends State<PendingTransactionBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _mountCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _mountCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _mountCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _mountCtrl, curve: Curves.easeOut));
    _mountCtrl.forward();
  }

  @override
  void dispose() {
    _mountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hide on non-Android
    if (kIsWeb || !Platform.isAndroid) return const SizedBox.shrink();

    return Consumer<PendingTransactionProvider>(
      builder: (context, provider, _) {
        if (!provider.hasPending) return const SizedBox.shrink();

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final count = provider.pendingCount;
        final previews = provider.previewItems;
        final currencyFmt = NumberFormat.currency(
          locale: 'en_IN',
          symbol: '₹',
          decimalDigits: 0,
        );

        return SlideTransition(
          position: _slide,
          child: FadeTransition(
            opacity: _fade,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: BounceTap(
                onTap: () => context.push('/pending-transactions'),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.kCyan.withValues(alpha: isDark ? 0.12 : 0.08),
                        AppColors.kViolet.withValues(alpha: isDark ? 0.08 : 0.04),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: AppColors.kCyan.withValues(alpha: isDark ? 0.25 : 0.15),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        // Bell icon with badge
                        _buildIcon(count, isDark),
                        const SizedBox(width: AppSpacing.md),

                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$count payment${count > 1 ? 's' : ''} detected',
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.kTextPrimary
                                      : AppColors.lightTextPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                previews.map((p) {
                                  final amt = currencyFmt.format(p.amount);
                                  final name = p.merchant ?? 'UPI';
                                  return '$amt to $name';
                                }).join(' · '),
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.kTextSecondary
                                      : AppColors.lightTextSecondary,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: AppSpacing.sm),

                        // Review button
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs + 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.accentGradient,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: const Text(
                            'Review',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIcon(int count, bool isDark) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.kCyan.withValues(alpha: isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Icon(
            LucideIcons.bellRing,
            color: AppColors.kCyan,
            size: 22,
          ),
        ),
        // Badge
        Positioned(
          top: -4,
          right: -4,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              gradient: AppColors.warmGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                count > 9 ? '9+' : '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
