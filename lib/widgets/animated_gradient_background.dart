import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/constants.dart';

/// Animated gradient mesh background for auth screens.
/// Creates a flowing, aurora-like effect.
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;

  const AnimatedGradientBackground({super.key, required this.child});

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Pre-computed orb decorations — avoid recreating on every frame
  static final _darkOrb1 = BoxDecoration(
    shape: BoxShape.circle,
    gradient: RadialGradient(colors: [
      AppColors.primary.withValues(alpha: 0.25),
      AppColors.primary.withValues(alpha: 0.0),
    ]),
  );
  static final _lightOrb1 = BoxDecoration(
    shape: BoxShape.circle,
    gradient: RadialGradient(colors: [
      AppColors.primary.withValues(alpha: 0.12),
      AppColors.primary.withValues(alpha: 0.0),
    ]),
  );
  static final _darkOrb2 = BoxDecoration(
    shape: BoxShape.circle,
    gradient: RadialGradient(colors: [
      AppColors.accent.withValues(alpha: 0.15),
      AppColors.accent.withValues(alpha: 0.0),
    ]),
  );
  static final _lightOrb2 = BoxDecoration(
    shape: BoxShape.circle,
    gradient: RadialGradient(colors: [
      AppColors.accent.withValues(alpha: 0.08),
      AppColors.accent.withValues(alpha: 0.0),
    ]),
  );
  static final _darkOrb3 = BoxDecoration(
    shape: BoxShape.circle,
    gradient: RadialGradient(colors: [
      AppColors.gradientPink.withValues(alpha: 0.12),
      AppColors.gradientPink.withValues(alpha: 0.0),
    ]),
  );
  static final _lightOrb3 = BoxDecoration(
    shape: BoxShape.circle,
    gradient: RadialGradient(colors: [
      AppColors.gradientPink.withValues(alpha: 0.06),
      AppColors.gradientPink.withValues(alpha: 0.0),
    ]),
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;

    return Container(
      decoration: BoxDecoration(color: bgColor),
      child: Stack(
        children: [
          // Animated gradient orbs — isolated in RepaintBoundary
          // so child content doesn't rebuild every animation frame
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Stack(
                    children: [
                      // Gradient orb 1
                      Positioned(
                        top: -80 + 30 * math.sin(_controller.value * 2 * math.pi),
                        right: -60 + 20 * math.cos(_controller.value * 2 * math.pi),
                        child: Container(
                          width: 300,
                          height: 300,
                          decoration: isDark ? _darkOrb1 : _lightOrb1,
                        ),
                      ),
                      // Gradient orb 2
                      Positioned(
                        bottom: 100 + 40 * math.cos(_controller.value * 2 * math.pi + 1),
                        left: -100 + 30 * math.sin(_controller.value * 2 * math.pi + 2),
                        child: Container(
                          width: 350,
                          height: 350,
                          decoration: isDark ? _darkOrb2 : _lightOrb2,
                        ),
                      ),
                      // Gradient orb 3
                      Positioned(
                        top: 200 + 25 * math.sin(_controller.value * 2 * math.pi + 3),
                        left: 100 + 35 * math.cos(_controller.value * 2 * math.pi + 1),
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: isDark ? _darkOrb3 : _lightOrb3,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          // Content — outside AnimatedBuilder for zero-cost repaints
          widget.child,
        ],
      ),
    );
  }
}

