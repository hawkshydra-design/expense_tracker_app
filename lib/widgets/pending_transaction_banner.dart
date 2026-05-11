import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/pending_transaction_provider.dart';
import '../utils/constants.dart';

/// Dashboard banner showing count of auto-detected pending payments.
///
/// Displays a gradient card with pending count, top 2 preview items,
/// and a "Review" button. Hidden on non-Android platforms or when
/// no pending transactions exist.
class PendingTransactionBanner extends StatelessWidget {
  const PendingTransactionBanner({super.key});

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

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        AppColors.accent.withValues(alpha: 0.12),
                        AppColors.primary.withValues(alpha: 0.08),
                      ]
                    : [
                        AppColors.accent.withValues(alpha: 0.08),
                        AppColors.primary.withValues(alpha: 0.04),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: AppColors.accent
                    .withValues(alpha: isDark ? 0.25 : 0.15),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.push('/pending-transactions'),
                borderRadius: BorderRadius.circular(AppRadius.xl),
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
                                    ? AppColors.darkTextPrimary
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
                                    ? AppColors.darkTextSecondary
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
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
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
        )
            .animate()
            .fadeIn(duration: 500.ms)
            .slideY(begin: -0.15, duration: 500.ms, curve: Curves.easeOut)
            .shimmer(
              delay: 500.ms,
              duration: 1500.ms,
              color: AppColors.accent.withValues(alpha: 0.08),
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
            color:
                AppColors.accent.withValues(alpha: isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Icon(
            Icons.notifications_active_rounded,
            color: AppColors.accent,
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
