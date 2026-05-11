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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // All auth + OTP logic is in AuthProvider — no getIt access needed
    final authProvider = context.read<AuthProvider>();
    final result = await authProvider.initiateLogin(
      email: email,
      password: password,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.isSuccess) {
      // Credentials valid, OTP sent — navigate to OTP screen
      // Password is stored securely in AuthProvider memory, NOT in route params
      context.push('/otp');
    } else {
      setState(() => _error = result.errorOrNull?.message ?? 'Login failed');
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
                  const SizedBox(height: AppSpacing.xxl),

                  // Header
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: AppShadows.glowPrimary,
                      ),
                      child: const Icon(Icons.lock_rounded,
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
                      'Welcome Back',
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
                      'Sign in to continue managing your expenses',
                      style: TextStyle(fontSize: 14, color: subtitleColor),
                      textAlign: TextAlign.center,
                    ),
                  ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

                  const SizedBox(height: AppSpacing.xxl),

                  // Error banner
                  if (_error != null)
                    ErrorBanner(
                      message: _error!,
                      onDismiss: () => setState(() => _error = null),
                    )
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: -0.2),

                  if (_error != null) const SizedBox(height: AppSpacing.md),

                  // Email field
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
                      .fadeIn(delay: 350.ms, duration: 400.ms)
                      .slideX(begin: -0.1, delay: 350.ms),

                  const SizedBox(height: AppSpacing.md),

                  // Password field
                  AppTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleLogin(),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      if (v.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  )
                      .animate()
                      .fadeIn(delay: 450.ms, duration: 400.ms)
                      .slideX(begin: -0.1, delay: 450.ms),

                  const SizedBox(height: AppSpacing.sm),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push('/forgot-password'),
                      child: const Text('Forgot Password?',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ).animate().fadeIn(delay: 550.ms, duration: 300.ms),

                  const SizedBox(height: AppSpacing.lg),

                  // Login button
                  GradientButton(
                    text: 'Sign In',
                    isLoading: _isLoading,
                    onPressed: _handleLogin,
                    icon: Icons.arrow_forward_rounded,
                  )
                      .animate()
                      .fadeIn(delay: 650.ms, duration: 400.ms)
                      .slideY(begin: 0.2, delay: 650.ms),

                  const SizedBox(height: AppSpacing.xxl),

                  // Divider
                  Row(
                    children: [
                      Expanded(
                          child: Divider(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder)),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md),
                        child: Text('OR',
                            style: TextStyle(
                                color: subtitleColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                          child: Divider(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder)),
                    ],
                  ).animate().fadeIn(delay: 750.ms, duration: 300.ms),

                  const SizedBox(height: AppSpacing.lg),

                  // Sign up link
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Don't have an account? ",
                            style: TextStyle(color: subtitleColor)),
                        GestureDetector(
                          onTap: () => context.pushReplacement('/signup'),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 850.ms, duration: 300.ms),

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
