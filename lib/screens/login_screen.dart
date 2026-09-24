import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/email_validator.dart';
import '../utils/password_validator.dart';
import '../widgets/app_text_field.dart';
import '../widgets/gradient_button.dart';
import '../widgets/error_banner.dart';
import '../widgets/bounce_tap.dart';

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
  bool _isGoogleLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Email/Password login — goes directly to Home (no OTP step)
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final authProvider = context.read<AuthProvider>();
    final result = await authProvider.login(
      email: email,
      password: password,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.isSuccess) {
      context.go('/home');
    } else {
      setState(() => _error = result.errorOrNull?.message ?? 'Login failed');
    }
  }

  /// Google Sign-In — works for both login and new account
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleLoading = true;
      _error = null;
    });

    final authProvider = context.read<AuthProvider>();
    final result = await authProvider.signInWithGoogle();

    if (!mounted) return;

    setState(() => _isGoogleLoading = false);

    if (result.isSuccess) {
      context.go('/home');
    } else {
      final errorMsg = result.errorOrNull?.message;
      // Don't show error if user just cancelled the popup
      if (errorMsg != null && errorMsg != 'Sign-in cancelled') {
        setState(() => _error = errorMsg);
      }
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xxl),

                // ─── Logo ─────────────────────────────────
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.kViolet,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: AppShadows.glowViolet,
                    ),
                    child: const Icon(LucideIcons.wallet,
                        color: Colors.white, size: 32),
                  ),
                )
                    .animate()
                    .scaleXY(begin: 0.0, duration: 500.ms, curve: Curves.elasticOut),

                const SizedBox(height: AppSpacing.lg),

                // ─── Title ────────────────────────────────
                const Center(
                  child: Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.kTextPrimary,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 150.ms, duration: 400.ms),

                const SizedBox(height: AppSpacing.sm),

                // ─── Subtitle ─────────────────────────────
                const Center(
                  child: Text(
                    'Sign in to continue managing your expenses',
                    style: TextStyle(fontSize: 14, color: AppColors.kTextSecondary),
                    textAlign: TextAlign.center,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 250.ms, duration: 400.ms),

                const SizedBox(height: AppSpacing.xxl),

                // ─── Error ────────────────────────────────
                if (_error != null) ...[
                  ErrorBanner(
                    message: _error!,
                    onDismiss: () => setState(() => _error = null),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                // ─── Email field ──────────────────────────
                AppTextField(
                  controller: _emailController,
                  hintText: 'Email address',
                  prefixIcon: LucideIcons.mail,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: EmailValidator.validate,
                )
                    .animate()
                    .fadeIn(delay: 350.ms, duration: 400.ms)
                    .slideY(begin: 0.2, curve: Curves.easeOutCubic),

                const SizedBox(height: AppSpacing.md),

                // ─── Password field ───────────────────────
                AppTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  prefixIcon: LucideIcons.lock,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleLogin(),
                  validator: PasswordValidator.validateLogin,
                )
                    .animate()
                    .fadeIn(delay: 430.ms, duration: 400.ms)
                    .slideY(begin: 0.2, curve: Curves.easeOutCubic),

                const SizedBox(height: AppSpacing.sm),

                // ─── Forgot password ──────────────────────
                Align(
                  alignment: Alignment.centerRight,
                  child: BounceTap(
                    onTap: () => context.push('/forgot-password'),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: AppColors.kViolet,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 530.ms, duration: 400.ms),

                const SizedBox(height: AppSpacing.lg),

                // ─── Login button ─────────────────────────
                GradientButton(
                  text: 'Sign In',
                  isLoading: _isLoading,
                  onPressed: _handleLogin,
                  icon: LucideIcons.arrowRight,
                )
                    .animate()
                    .fadeIn(delay: 630.ms, duration: 400.ms),

                const SizedBox(height: AppSpacing.xxl),

                // ─── Divider ──────────────────────────────
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.kCardBorder)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: AppColors.kTextMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.kCardBorder)),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 750.ms, duration: 400.ms),

                const SizedBox(height: AppSpacing.lg),

                // ─── Google Sign-In button ─────────────────
                BounceTap(
                  onTap: _isGoogleLoading ? null : _handleGoogleSignIn,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border.all(color: AppColors.kCardBorder),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: _isGoogleLoading
                        ? const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: Image.asset(
                                  'assets/images/google_logo.png',
                                  height: 20,
                                  width: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Continue with Google',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: AppColors.kTextPrimary,
                                ),
                              ),
                            ],
                          ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 830.ms, duration: 400.ms),

                const SizedBox(height: AppSpacing.xl),

                // ─── Sign up link ─────────────────────────
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Don't have an account? ",
                          style: TextStyle(color: AppColors.kTextSecondary)),
                      BounceTap(
                        onTap: () => context.pushReplacement('/signup'),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: AppColors.kViolet,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 900.ms, duration: 400.ms),

                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
