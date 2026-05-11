import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

/// Expandable Floating Action Button with animated sub-actions.
/// Inspired by Material 3 extended FAB pattern.
class ExpandableFab extends StatefulWidget {
  final List<FabAction> actions;
  final VoidCallback? onMainPressed;

  const ExpandableFab({
    super.key,
    required this.actions,
    this.onMainPressed,
  });

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<CurvedAnimation> _itemAnimations;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.fabExpand,
    );
    _buildItemAnimations();
  }

  void _buildItemAnimations() {
    _itemAnimations = List.generate(widget.actions.length, (index) {
      final delay = index * 0.1;
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(delay, 1.0, curve: Curves.easeOutBack),
      );
    });
  }

  @override
  void didUpdateWidget(ExpandableFab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.actions.length != widget.actions.length) {
      _disposeItemAnimations();
      _buildItemAnimations();
    }
  }

  void _disposeItemAnimations() {
    for (final anim in _itemAnimations) {
      anim.dispose();
    }
  }

  @override
  void dispose() {
    _disposeItemAnimations();
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 300,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Scrim
          if (_isOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggle,
                child: const SizedBox.expand(),
              ),
            ),
          // Sub-actions
          ...widget.actions.asMap().entries.map((entry) {
            final index = entry.key;
            final action = entry.value;
            return _buildSubAction(action, index);
          }),
          // Main FAB
          _buildMainFab(),
        ],
      ),
    );
  }

  Widget _buildSubAction(FabAction action, int index) {
    final animation = _itemAnimations[index];

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final offset = (index + 1) * 64.0 * animation.value;
        return Positioned(
          bottom: offset + 8,
          right: 4,
          child: Opacity(
            opacity: animation.value.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: animation.value.clamp(0.0, 1.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Label
                  if (action.label != null)
                    Container(
                      margin: const EdgeInsets.only(right: AppSpacing.sm),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkCard
                            : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        action.label!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  // Icon button
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: FloatingActionButton(
                      heroTag: 'fab_action_$index',
                      onPressed: () {
                        _toggle();
                        action.onPressed();
                      },
                      elevation: 4,
                      backgroundColor: action.color ?? AppColors.primarySoft,
                      foregroundColor: action.iconColor ?? AppColors.primaryDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(action.icon, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainFab() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FloatingActionButton(
          heroTag: 'main_fab',
          onPressed: _toggle,
          elevation: 8,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Transform.rotate(
            angle: _controller.value * pi / 4,
            child: Icon(
              _isOpen ? Icons.close_rounded : Icons.add_rounded,
              size: 28,
            ),
          ),
        );
      },
    );
  }
}

/// Data model for a single FAB action
class FabAction {
  final IconData icon;
  final String? label;
  final VoidCallback onPressed;
  final Color? color;
  final Color? iconColor;

  const FabAction({
    required this.icon,
    this.label,
    required this.onPressed,
    this.color,
    this.iconColor,
  });
}
