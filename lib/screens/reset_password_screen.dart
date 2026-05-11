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

/// Reset password screen — reads pending email from AuthProvider.
/// No constructor params needed — email comes from the pending auth flow.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // All auth logic through AuthProvider — no getIt access
    final authProvider = context.read<AuthProvider>();
    final result = await authProvider.resetPassword(
      newPassword: _passwordController.text,
    );

    if (!mounted) return;

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Password updated successfully! Please login with your new password.'),
          backgroundColor: AppColors.success,
        ),
      );
      // Navigate to login and clear the entire stack
      context.go('/login');
    } else {
      setState(() {
        _isLoading = false;
        _error = result.errorOrNull?.message ?? 'Failed to update password';
      });
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
                      gradient: AppColors.successGradient,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withValues(alpha: 0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.password_rounded,
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
                    'Reset Password',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: textColor),
                  ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    'Create a new password for your account',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: subtitleColor),
                  ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

                  const SizedBox(height: AppSpacing.xl),

                  if (_error != null)
                    ErrorBanner(
                      message: _error!,
                      onDismiss: () => setState(() => _error = null),
                    ).animate().fadeIn(duration: 300.ms),

                  if (_error != null) const SizedBox(height: AppSpacing.md),

                  AppTextField(
                    controller: _passwordController,
                    hintText: 'New Password',
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      if (v.length < 6) return 'Min 6 characters';
                      if (!RegExp(r'[A-Z]').hasMatch(v)) {
                        return 'Include an uppercase letter';
                      }
                      if (!RegExp(r'[0-9]').hasMatch(v)) {
                        return 'Include a number';
                      }
                      return null;
                    },
                  )
                      .animate()
                      .fadeIn(delay: 350.ms, duration: 400.ms)
                      .slideX(begin: -0.1, delay: 350.ms),

                  const SizedBox(height: AppSpacing.md),

                  AppTextField(
                    controller: _confirmController,
                    hintText: 'Confirm New Password',
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleReset(),
                    validator: (v) {
                      if (v != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  )
                      .animate()
                      .fadeIn(delay: 450.ms, duration: 400.ms)
                      .slideX(begin: -0.1, delay: 450.ms),

                  const SizedBox(height: AppSpacing.xl),

                  GradientButton(
                    text: 'Update Password',
                    isLoading: _isLoading,
                    onPressed: _handleReset,
                    gradient: AppColors.successGradient,
                    icon: Icons.check_circle_rounded,
                  ).animate().fadeIn(delay: 550.ms, duration: 400.ms),

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
