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
  bool _isGoogleLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  /// Email/Password signup — direct to Home (no OTP step)
  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final authProvider = context.read<AuthProvider>();
    final result = await authProvider.signup(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.isSuccess) {
      context.go('/home');
    } else {
      setState(() => _error = result.errorOrNull?.message ?? 'Signup failed');
    }
  }

  /// Google Sign-Up — same API as sign-in, Firebase auto-creates account
  Future<void> _handleGoogleSignUp() async {
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
                const SizedBox(height: AppSpacing.xl),

                // Back button
                BounceTap(
                  onTap: () => context.pop(),
                  child: const Icon(LucideIcons.arrowLeft,
                      color: AppColors.kTextPrimary),
                )
                    .animate()
                    .fadeIn(duration: 300.ms),

                const SizedBox(height: AppSpacing.md),

                // Logo
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.kCyan.withValues(alpha: 0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(LucideIcons.userPlus,
                        color: Colors.white, size: 32),
                  ),
                )
                    .animate()
                    .scaleXY(begin: 0.0, duration: 500.ms, curve: Curves.elasticOut),

                const SizedBox(height: AppSpacing.lg),

                // Title
                const Center(
                  child: Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.kTextPrimary,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 120.ms, duration: 400.ms)
                    .slideY(begin: 0.15, curve: Curves.easeOutCubic),

                const SizedBox(height: AppSpacing.sm),

                // Subtitle
                const Center(
                  child: Text(
                    'Start tracking your expenses today',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.kTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 220.ms, duration: 400.ms),

                const SizedBox(height: AppSpacing.xl),

                // Error
                if (_error != null) ...[
                  ErrorBanner(
                    message: _error!,
                    onDismiss: () => setState(() => _error = null),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                // ─── Google Sign-Up button ─────────────────
                BounceTap(
                  onTap: _isGoogleLoading ? null : _handleGoogleSignUp,
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
                                'Sign up with Google',
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
                    .fadeIn(delay: 280.ms, duration: 400.ms),

                const SizedBox(height: AppSpacing.lg),

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
                    .fadeIn(delay: 340.ms, duration: 400.ms),

                const SizedBox(height: AppSpacing.lg),

                // Full name
                AppTextField(
                  controller: _nameController,
                  hintText: 'Full Name',
                  prefixIcon: LucideIcons.user,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Name is required';
                    if (v.trim().length < 2) return 'Name too short';
                    return null;
                  },
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 400.ms)
                    .slideY(begin: 0.2, curve: Curves.easeOutCubic),

                const SizedBox(height: AppSpacing.md),

                // Email
                AppTextField(
                  controller: _emailController,
                  hintText: 'Email address',
                  prefixIcon: LucideIcons.mail,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: EmailValidator.validate,
                )
                    .animate()
                    .fadeIn(delay: 470.ms, duration: 400.ms)
                    .slideY(begin: 0.2, curve: Curves.easeOutCubic),

                const SizedBox(height: AppSpacing.md),

                // Password
                AppTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  prefixIcon: LucideIcons.lock,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  validator: PasswordValidator.validateStrict,
                )
                    .animate()
                    .fadeIn(delay: 540.ms, duration: 400.ms)
                    .slideY(begin: 0.2, curve: Curves.easeOutCubic),

                const SizedBox(height: AppSpacing.md),

                // Confirm password
                AppTextField(
                  controller: _confirmController,
                  hintText: 'Confirm Password',
                  prefixIcon: LucideIcons.lock,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleSignup(),
                  validator: (v) {
                    if (v != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                )
                    .animate()
                    .fadeIn(delay: 610.ms, duration: 400.ms)
                    .slideY(begin: 0.2, curve: Curves.easeOutCubic),

                const SizedBox(height: AppSpacing.xl),

                // Signup button
                GradientButton(
                  text: 'Create Account',
                  isLoading: _isLoading,
                  onPressed: _handleSignup,
                  gradient: AppColors.accentGradient,
                  icon: LucideIcons.arrowRight,
                )
                    .animate()
                    .fadeIn(delay: 730.ms, duration: 400.ms),

                const SizedBox(height: AppSpacing.xl),

                // Login link
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Already have an account? ',
                          style: TextStyle(color: AppColors.kTextSecondary)),
                      BounceTap(
                        onTap: () => context.pushReplacement('/login'),
                        child: const Text(
                          'Sign In',
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
                    .fadeIn(delay: 830.ms, duration: 400.ms),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
