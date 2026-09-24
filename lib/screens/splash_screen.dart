import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../screens/terms_consent_screen.dart';
import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    final authProvider = context.read<AuthProvider>();
    final expenseProvider = context.read<ExpenseProvider>();

    await Future.delayed(AppDurations.splashDuration);

    // Firebase persists auth state automatically — just check if user exists
    final isLoggedIn = await authProvider.tryAutoLogin();

    if (!mounted) return;

    if (isLoggedIn) {
      await expenseProvider.setUser(authProvider.userId);

      // Check if user has accepted terms
      final hasAcceptedTerms = await TermsConsentScreen.hasAccepted();

      if (!mounted) return;
      context.go(hasAcceptedTerms ? '/home' : '/terms-consent');
    } else {
      if (!mounted) return;
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.kTextPrimary : AppColors.lightTextPrimary;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                boxShadow: AppShadows.glowViolet,
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
                .animate()
                .scaleXY(begin: 0.0, duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: AppSpacing.lg),

            // Title
            const Text(
              'Expense Tracker',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 500.ms),
            const SizedBox(height: AppSpacing.sm),

            // Subtitle
            Text(
              'Track smarter. Save more.',
              style: TextStyle(
                fontSize: 14,
                color: textColor.withValues(alpha: 0.6),
              ),
            )
                .animate()
                .fadeIn(delay: 350.ms, duration: 500.ms),
            const SizedBox(height: AppSpacing.xxl),

            // Spinner
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.kViolet.withValues(alpha: 0.7),
              ),
              strokeWidth: 2,
            )
                .animate()
                .fadeIn(delay: 500.ms, duration: 500.ms),
          ],
        ),
      ),
    );
  }
}
