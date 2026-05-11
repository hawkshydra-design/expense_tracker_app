import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../utils/constants.dart';
import '../widgets/animated_gradient_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _controller.forward();
    _navigate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    // Capture providers synchronously before async gaps
    final authProvider = context.read<AuthProvider>();
    final expenseProvider = context.read<ExpenseProvider>();

    await Future.delayed(AppDurations.splashDuration);

    final isLoggedIn = await authProvider.tryAutoLogin();

    if (!mounted) return;

    if (isLoggedIn) {
      await expenseProvider.setUser(authProvider.userId);
    }

    if (!mounted) return;

    context.go(isLoggedIn ? '/home' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Scaffold(
      body: AnimatedGradientBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 32,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    fit: BoxFit.contain,
                    cacheWidth: 256,
                  ),
                ),
              )
                  .animate(controller: _controller)
                  .scale(
                    begin: const Offset(0.3, 0.3),
                    end: const Offset(1, 1),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 400.ms),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Expense Tracker',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: -0.5,
                ),
              )
                  .animate(controller: _controller)
                  .fadeIn(delay: 300.ms, duration: 500.ms)
                  .slideY(begin: 0.3, delay: 300.ms),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Track smarter. Save more.',
                style: TextStyle(
                  fontSize: 14,
                  color: textColor.withValues(alpha: 0.6),
                ),
              )
                  .animate(controller: _controller)
                  .fadeIn(delay: 500.ms, duration: 500.ms),
              const SizedBox(height: AppSpacing.xxl),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primary.withValues(alpha: 0.7),
                ),
                strokeWidth: 2,
              )
                  .animate(controller: _controller)
                  .fadeIn(delay: 700.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
