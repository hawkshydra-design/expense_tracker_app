import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../widgets/app_text_field.dart';
import '../widgets/gradient_button.dart';
import '../widgets/error_banner.dart';
import '../widgets/bounce_tap.dart';

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

  bool _emailSent = false;

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
    final authProvider = context.read<AuthProvider>();
    final result = await authProvider.forgotPassword(email: email);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.isSuccess) {
      setState(() => _emailSent = true);
    } else {
      setState(() => _error = result.errorOrNull?.message ?? 'Failed to send reset email');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.xl),

                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: BounceTap(
                    onTap: () => context.pop(),
                    child: const Icon(LucideIcons.arrowLeft, color: AppColors.kTextPrimary),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 300.ms),

                const SizedBox(height: AppSpacing.lg),

                // Icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: AppColors.warmGradient,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.kRose.withValues(alpha: 0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(LucideIcons.keyRound, color: Colors.white, size: 32),
                )
                    .animate()
                    .scaleXY(begin: 0.0, duration: 500.ms, curve: Curves.elasticOut),

                const SizedBox(height: AppSpacing.lg),

                // Title
                const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.kTextPrimary,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 180.ms, duration: 400.ms),

                const SizedBox(height: AppSpacing.sm),

                // Subtitle
                const Text(
                  'Enter your email and we\'ll send a link to reset your password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.kTextSecondary, height: 1.5),
                )
                    .animate()
                    .fadeIn(delay: 280.ms, duration: 400.ms),

                const SizedBox(height: AppSpacing.xl),

                // Success message or form
                if (_emailSent) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.kGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.kGreen.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.checkCircle, color: AppColors.kGreen, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Reset link sent to ${_emailController.text.trim()}. Check your inbox.',
                            style: const TextStyle(color: AppColors.kTextPrimary, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1, curve: Curves.easeOutCubic),
                  const SizedBox(height: AppSpacing.xl),
                  GradientButton(
                    text: 'Back to Sign In',
                    onPressed: () => context.go('/login'),
                    gradient: AppColors.warmGradient,
                    icon: LucideIcons.arrowLeft,
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 400.ms),
                ] else ...[
                  // Error
                  if (_error != null) ...[
                    ErrorBanner(
                      message: _error!,
                      onDismiss: () => setState(() => _error = null),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // Email field
                  AppTextField(
                    controller: _emailController,
                    hintText: 'Email address',
                    prefixIcon: LucideIcons.mail,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleSubmit(),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email is required';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 400.ms)
                      .slideY(begin: 0.2, curve: Curves.easeOutCubic),

                  const SizedBox(height: AppSpacing.xl),

                  // Submit button
                  GradientButton(
                    text: 'Send Reset Link',
                    isLoading: _isLoading,
                    onPressed: _handleSubmit,
                    gradient: AppColors.warmGradient,
                    icon: LucideIcons.send,
                  )
                      .animate()
                      .fadeIn(delay: 550.ms, duration: 400.ms),
                ],

                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
