import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../services/email_service.dart';
import '../utils/constants.dart';
import '../widgets/gradient_button.dart';
import '../widgets/error_banner.dart';
import '../widgets/animated_gradient_background.dart';

/// OTP verification screen.
/// Reads pending email/purpose from AuthProvider — no route params needed.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isVerifying = false;
  String? _error;
  int _resendCooldown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _resendCooldown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        t.cancel();
      }
    });
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  Future<void> _verifyOtp() async {
    // Guard against double-fire (auto-trigger + button press race condition)
    if (_isVerifying) return;

    if (_otpCode.length != 6) {
      setState(() => _error = 'Please enter the complete 6-digit code');
      return;
    }

    setState(() {
      _isVerifying = true;
      _error = null;
    });

    // All verification logic through AuthProvider
    final authProvider = context.read<AuthProvider>();
    final result = await authProvider.verifyOtp(code: _otpCode);

    if (!mounted) return;

    if (result.isFailure) {
      setState(() {
        _isVerifying = false;
        _error = result.errorOrNull?.message ?? 'Verification failed';
      });
      return;
    }

    final purpose = result.valueOrNull;

    if (purpose == 'signup' || purpose == 'login') {
      // Auth completed — load expenses and go home
      final expenseProvider = context.read<ExpenseProvider>();
      await expenseProvider.setUser(authProvider.userId);
      if (!mounted) return;
      context.go('/home');
    } else if (purpose == 'reset') {
      // OTP verified for reset — go to password reset form
      setState(() => _isVerifying = false);
      if (!mounted) return;
      context.pushReplacement('/reset-password');
    }
  }

  Future<void> _resendOtp() async {
    if (_resendCooldown > 0) return;

    final authProvider = context.read<AuthProvider>();
    final result = await authProvider.resendOtp();

    if (result.isSuccess) {
      _startTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New verification code sent!')),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                result.errorOrNull?.message ?? 'Failed to resend code')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cellBg = isDark ? AppColors.darkCardAlt : AppColors.lightCardAlt;
    final cellBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    // Read pending email from AuthProvider (no route params)
    final authProvider = context.watch<AuthProvider>();
    final email = authProvider.pendingEmail ?? '';

    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.xl),

                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {
                      authProvider.clearPending();
                      context.pop();
                    },
                    icon: Icon(Icons.arrow_back_rounded, color: textColor),
                  ),
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: AppSpacing.lg),

                // Icon
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
                  child: const Icon(Icons.mark_email_read_rounded,
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
                  'Verify Your Email',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: textColor),
                ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  'We sent a 6-digit code to\n${EmailService.maskEmail(email)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14, color: subtitleColor, height: 1.5),
                ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

                const SizedBox(height: AppSpacing.xl),

                // Error
                if (_error != null)
                  ErrorBanner(
                    message: _error!,
                    onDismiss: () => setState(() => _error = null),
                  ).animate().fadeIn(duration: 300.ms),

                if (_error != null) const SizedBox(height: AppSpacing.md),

                // OTP Input cells
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (i) {
                    return Container(
                      width: 48,
                      height: 56,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextField(
                        controller: _controllers[i],
                        focusNode: _focusNodes[i],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: cellBg,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.md),
                            borderSide: BorderSide(color: cellBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.md),
                            borderSide: BorderSide(
                                color:
                                    cellBorder.withValues(alpha: 0.5)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.md),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 2),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (v) {
                          if (v.isNotEmpty && i < 5) {
                            _focusNodes[i + 1].requestFocus();
                          }
                          if (v.isEmpty && i > 0) {
                            _focusNodes[i - 1].requestFocus();
                          }
                          if (_otpCode.length == 6) _verifyOtp();
                        },
                      ),
                    );
                  }),
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 400.ms)
                    .slideY(begin: 0.2, delay: 400.ms),

                const SizedBox(height: AppSpacing.xl),

                // Verify button
                GradientButton(
                  text: 'Verify Code',
                  isLoading: _isVerifying,
                  onPressed: _verifyOtp,
                  gradient: AppColors.successGradient,
                ).animate().fadeIn(delay: 550.ms, duration: 400.ms),

                const SizedBox(height: AppSpacing.lg),

                // Resend
                TextButton(
                  onPressed: _resendCooldown == 0 ? _resendOtp : null,
                  child: Text(
                    _resendCooldown > 0
                        ? 'Resend code in ${_resendCooldown}s'
                        : 'Resend Code',
                    style: TextStyle(
                      color: _resendCooldown > 0
                          ? subtitleColor
                          : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ).animate().fadeIn(delay: 650.ms, duration: 300.ms),

                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
