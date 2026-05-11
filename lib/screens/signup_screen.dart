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

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // All auth + OTP logic through AuthProvider — no getIt access
    final authProvider = context.read<AuthProvider>();
    final result = await authProvider.initiateSignup(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.isSuccess) {
      // OTP sent — navigate to verification screen
      // Credentials stored in AuthProvider memory, NOT in route params
      context.push('/otp');
    } else {
      setState(() => _error = result.errorOrNull?.message ?? 'Signup failed');
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xl),

                  // Back button
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.arrow_back_rounded, color: textColor),
                  ).animate().fadeIn(duration: 300.ms),

                  const SizedBox(height: AppSpacing.md),

                  // Header
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.3),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.person_add_rounded,
                          color: Colors.white, size: 32),
                    ),
                  )
                      .animate()
                      .scale(
                          begin: const Offset(0.5, 0.5),
                          duration: 500.ms,
                          curve: Curves.elasticOut)
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: AppSpacing.lg),

                  Center(
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: textColor),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 150.ms, duration: 400.ms)
                      .slideY(begin: 0.2, delay: 150.ms),

                  const SizedBox(height: AppSpacing.sm),

                  Center(
                    child: Text(
                      'Start tracking your expenses today',
                      style: TextStyle(fontSize: 14, color: subtitleColor),
                      textAlign: TextAlign.center,
                    ),
                  ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

                  const SizedBox(height: AppSpacing.xl),

                  // Error banner
                  if (_error != null)
                    ErrorBanner(
                      message: _error!,
                      onDismiss: () => setState(() => _error = null),
                    ).animate().fadeIn(duration: 300.ms),

                  if (_error != null) const SizedBox(height: AppSpacing.md),

                  // Full name
                  AppTextField(
                    controller: _nameController,
                    hintText: 'Full Name',
                    prefixIcon: Icons.person_outline_rounded,
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Name is required';
                      }
                      if (v.trim().length < 2) return 'Name too short';
                      return null;
                    },
                  )
                      .animate()
                      .fadeIn(delay: 350.ms, duration: 400.ms)
                      .slideX(begin: -0.1, delay: 350.ms),

                  const SizedBox(height: AppSpacing.md),

                  // Email
                  AppTextField(
                    controller: _emailController,
                    hintText: 'Email address',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
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
                      .fadeIn(delay: 450.ms, duration: 400.ms)
                      .slideX(begin: -0.1, delay: 450.ms),

                  const SizedBox(height: AppSpacing.md),

                  // Password
                  AppTextField(
                    controller: _passwordController,
                    hintText: 'Password',
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
                      .fadeIn(delay: 550.ms, duration: 400.ms)
                      .slideX(begin: -0.1, delay: 550.ms),

                  const SizedBox(height: AppSpacing.md),

                  // Confirm password
                  AppTextField(
                    controller: _confirmController,
                    hintText: 'Confirm Password',
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleSignup(),
                    validator: (v) {
                      if (v != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  )
                      .animate()
                      .fadeIn(delay: 650.ms, duration: 400.ms)
                      .slideX(begin: -0.1, delay: 650.ms),

                  const SizedBox(height: AppSpacing.xl),

                  // Signup button
                  GradientButton(
                    text: 'Create Account',
                    isLoading: _isLoading,
                    onPressed: _handleSignup,
                    gradient: AppColors.accentGradient,
                    icon: Icons.arrow_forward_rounded,
                  )
                      .animate()
                      .fadeIn(delay: 750.ms, duration: 400.ms)
                      .slideY(begin: 0.2, delay: 750.ms),

                  const SizedBox(height: AppSpacing.xl),

                  // Login link
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Already have an account? ',
                            style: TextStyle(color: subtitleColor)),
                        GestureDetector(
                          onTap: () => context.pushReplacement('/login'),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 850.ms, duration: 300.ms),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
