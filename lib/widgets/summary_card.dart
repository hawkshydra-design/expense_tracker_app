import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import '../utils/constants.dart';

/// Summary card for displaying aggregate values on dashboard.
/// Uses M3 Expressive asymmetric shape + spring tap animation.
class SummaryCard extends StatefulWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Gradient gradient;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.gradient,
  });

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _tapController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: SpringTokens.duration,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: SpringTokens.tapScale,
    ).animate(CurvedAnimation(
      parent: _tapController,
      curve: SpringTokens.curve,
    ));
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.kTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.kTextSecondary : AppColors.lightTextSecondary;
    final cardColor = isDark ? AppColors.kSurface : AppColors.lightCard;

    return GestureDetector(
      onTapDown: (_) => _tapController.forward(),
      onTapUp: (_) => _tapController.reverse(),
      onTapCancel: () => _tapController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: ExpressiveShapes.tileA,
            border: Border.all(
              color: isDark ? AppColors.kCardBorder : AppColors.lightBorder.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: widget.gradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon, color: Colors.white, size: 18),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(widget.title, style: TextStyle(color: subtitleColor, fontSize: 12)),
              const SizedBox(height: 2),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: widget.amount),
                duration: AppDurations.countUp,
                curve: Curves.easeOut,
                builder: (context, value, _) {
                  return Text(
                    context.read<CurrencyProvider>().format(value),
                    style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
