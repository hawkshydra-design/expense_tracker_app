import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/constants.dart';

/// A GestureDetector wrapper that provides elastic scale feedback on tap.
/// Drop-in replacement for InkWell — no ripple, no splash.
///
/// On tap down: scales to [scaleDown] (default 0.97, from SpringTokens).
/// On tap up/cancel: springs back to 1.0 with easeOutBack.
/// Respects `MediaQuery.disableAnimations` for accessibility.
class BounceTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleDown;
  final bool enableHaptic;

  const BounceTap({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleDown = SpringTokens.tapScale,
    this.enableHaptic = true,
  });

  @override
  State<BounceTap> createState() => _BounceTapState();
}

class _BounceTapState extends State<BounceTap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: SpringTokens.duration,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: widget.scaleDown)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: widget.scaleDown, end: 1.02)
            .chain(CurveTween(curve: SpringTokens.curve)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.02, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.enableHaptic) {
      HapticFeedback.lightImpact();
    }
    _controller.forward(from: 0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    // Respect reduce-motion accessibility setting
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return GestureDetector(
      onTap: widget.onTap != null ? _handleTap : null,
      onLongPress: widget.onLongPress,
      behavior: HitTestBehavior.opaque,
      child: reduceMotion
          ? widget.child
          : AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                );
              },
              child: widget.child,
            ),
    );
  }
}
