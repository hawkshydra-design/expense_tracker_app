import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../widgets/app_text_field.dart';
import '../widgets/gradient_button.dart';
import '../widgets/error_banner.dart';
import '../widgets/animated_gradient_background.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final email = _emailController.text.trim();

    // All logic through AuthProvider — no getIt access
    final authProvider = context.read<AuthProvider>();
    final result = await authProvider.initiateForgotPassword(email: email);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.isSuccess) {
      context.push('/otp');
    } else {
      setState(
          () => _error = result.errorOrNull?.message ?? 'Failed to send code');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xl),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(Icons.arrow_back_rounded, color: textColor),
                    ),
                  ).animate().fadeIn(duration: 300.ms),

                  const SizedBox(height: AppSpacing.lg),

                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: AppColors.warmGradient,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gradientPink.withValues(alpha: 0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.lock_reset_rounded,
                        color: Colors.white, size: 32),
                  )
                      .animate()
                      .scale(
                          begin: const Offset(0.5, 0.5),
                          duration: 500.ms,
                          curve: Curves.elasticOut)
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: AppSpacing.lg),

                  Text(
                    'Forgot Password?',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: textColor),
                  ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    'Enter your email and we\'ll send a verification code to reset your password.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14, color: subtitleColor, height: 1.5),
                  ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

                  const SizedBox(height: AppSpacing.xl),

                  if (_error != null)
                    ErrorBanner(
                      message: _error!,
                      onDismiss: () => setState(() => _error = null),
                    ).animate().fadeIn(duration: 300.ms),

                  if (_error != null) const SizedBox(height: AppSpacing.md),

                  AppTextField(
                    controller: _emailController,
                    hintText: 'Email address',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleSubmit(),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Email is required';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(v.trim())) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  )
                      .animate()
                      .fadeIn(delay: 350.ms, duration: 400.ms)
                      .slideX(begin: -0.1, delay: 350.ms),

                  const SizedBox(height: AppSpacing.xl),

                  GradientButton(
                    text: 'Send Reset Code',
                    isLoading: _isLoading,
                    onPressed: _handleSubmit,
                    gradient: AppColors.warmGradient,
                    icon: Icons.send_rounded,
                  ).animate().fadeIn(delay: 450.ms, duration: 400.ms),

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
