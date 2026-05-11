import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

/// A navigation item definition for [AnimatedBottomNavBar].
class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavItem({
    required this.icon,
    required this.label,
    IconData? activeIcon,
  }) : activeIcon = activeIcon ?? icon;
}

/// A premium animated bottom navigation bar with:
/// - Floating pill-shaped container with glassmorphism
/// - Smooth animated active indicator that slides between items
/// - Icon scale + bounce animation on selection
/// - Active item "pops up" with a subtle rise effect
/// - Dot indicator below the active icon
class AnimatedBottomNavBar extends StatefulWidget {
  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AnimatedBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<AnimatedBottomNavBar> createState() => _AnimatedBottomNavBarState();
}

class _AnimatedBottomNavBarState extends State<AnimatedBottomNavBar>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.05), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 15),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void didUpdateWidget(AnimatedBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
      _slideController.forward(from: 0);
      _bounceController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SafeArea(
        top: false,
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkCard.withValues(alpha: 0.95)
                : Colors.white.withValues(alpha: 0.97),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? AppColors.darkBorder.withValues(alpha: 0.3)
                  : AppColors.lightBorder.withValues(alpha: 0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              ),
              if (!isDark)
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Animated sliding indicator
                _buildSlidingIndicator(isDark),
                // Nav items
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(widget.items.length, (index) {
                    return Expanded(
                      child: _NavBarItem(
                        item: widget.items[index],
                        isSelected: widget.currentIndex == index,
                        bounceAnimation:
                            widget.currentIndex == index ? _bounceAnimation : null,
                        onTap: () => widget.onTap(index),
                        isDark: isDark,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlidingIndicator(bool isDark) {
    // AnimatedBuilder as a direct child of Stack, using LayoutBuilder
    // only to measure width without wrapping Positioned.
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / widget.items.length;
            // Interpolate position from previous to current
            final progress = Curves.easeOutCubic.transform(
              _slideController.isAnimating ? _slideController.value : 1.0,
            );
            final left = _previousIndex * itemWidth +
                (_slideController.isAnimating
                    ? (widget.currentIndex - _previousIndex) *
                        itemWidth *
                        progress
                    : (widget.currentIndex) * itemWidth);

            return Padding(
              padding: EdgeInsets.only(
                left: left + itemWidth * 0.12,
                top: 6,
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  width: itemWidth * 0.76,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.12),
                        AppColors.primaryDark
                            .withValues(alpha: isDark ? 0.15 : 0.06),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Uses Flutter's built-in AnimatedBuilder for all animation widgets.

class _NavBarItem extends StatelessWidget {
  final NavItem item;
  final bool isSelected;
  final Animation<double>? bounceAnimation;
  final VoidCallback onTap;
  final bool isDark;

  const _NavBarItem({
    required this.item,
    required this.isSelected,
    this.bounceAnimation,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.primary;
    final inactiveColor =
        isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
    final color = isSelected ? activeColor : inactiveColor;

    Widget iconWidget = AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Icon(
        isSelected ? item.activeIcon : item.icon,
        key: ValueKey(isSelected),
        color: color,
        size: isSelected ? 26 : 24,
      ),
    );

    // Apply bounce animation to selected item
    if (bounceAnimation != null) {
      final baseIcon = iconWidget;
      iconWidget = AnimatedBuilder(
        animation: bounceAnimation!,
        builder: (context, child) {
          return Transform.scale(
            scale: bounceAnimation!.value,
            child: child,
          );
        },
        child: baseIcon,
      );
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated vertical offset for selected item
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              transform: Matrix4.translationValues(
                0,
                isSelected ? -2 : 0,
                0,
              ),
              child: iconWidget,
            ),
            const SizedBox(height: 4),
            // Label with fade
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                color: color,
                fontSize: isSelected ? 11 : 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: isSelected ? 0.3 : 0,
              ),
              child: Text(item.label),
            ),
            const SizedBox(height: 3),
            // Animated dot indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              width: isSelected ? 6 : 0,
              height: isSelected ? 6 : 0,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : AppColors.primary.withValues(alpha: 0.0),
                    blurRadius: isSelected ? 6 : 0,
                    spreadRadius: isSelected ? 1 : 0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
