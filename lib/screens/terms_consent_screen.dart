import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../utils/constants.dart';
import '../utils/legal_text.dart';

/// One-time consent screen shown after first login/signup.
/// User must accept Terms & Conditions + Privacy Policy before using the app.
/// Acceptance is stored in SharedPreferences.
class TermsConsentScreen extends StatefulWidget {
  const TermsConsentScreen({super.key});

  /// Check if the user has already accepted terms
  static Future<bool> hasAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('terms_accepted') ?? false;
  }

  /// Mark terms as accepted
  static Future<void> markAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('terms_accepted', true);
    await prefs.setString(
        'terms_accepted_at', DateTime.now().toIso8601String());
  }

  @override
  State<TermsConsentScreen> createState() => _TermsConsentScreenState();
}

class _TermsConsentScreenState extends State<TermsConsentScreen> {
  bool _termsChecked = false;
  bool _privacyChecked = false;
  bool _showingTerms = false;
  bool _showingPrivacy = false;

  bool get _canProceed => _termsChecked && _privacyChecked;

  Future<void> _acceptAndContinue() async {
    if (!_canProceed) return;
    HapticFeedback.mediumImpact();
    await TermsConsentScreen.markAccepted();
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.kTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor =
        isDark ? AppColors.kTextSecondary : AppColors.lightTextSecondary;
    final cardColor = isDark ? AppColors.kSurface : AppColors.lightCard;
    final borderColor = isDark ? AppColors.kCardBorder : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),

              // Icon
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    boxShadow: AppShadows.glowViolet,
                  ),
                  child: const Icon(LucideIcons.shieldCheck,
                      color: Colors.white, size: 36),
                ),
              )
                  .animate()
                  .scaleXY(begin: 0.0, duration: 600.ms, curve: Curves.elasticOut),

              const SizedBox(height: AppSpacing.lg),

              // Title
              Text(
                'Privacy & Terms',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms),

              const SizedBox(height: AppSpacing.sm),

              Text(
                'Please review and accept our policies to continue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: subtitleColor,
                ),
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 400.ms),

              const SizedBox(height: AppSpacing.xl),

              // Data info card
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.kCyan.withValues(alpha: isDark ? 0.08 : 0.05),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                      color: AppColors.kCyan.withValues(alpha: 0.15)),
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: LucideIcons.smartphone,
                      text: 'Data stored locally on your device',
                      color: AppColors.kCyan,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _InfoRow(
                      icon: LucideIcons.shieldOff,
                      text: 'No data shared with third parties',
                      color: AppColors.kCyan,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _InfoRow(
                      icon: LucideIcons.cloudOff,
                      text: 'No tracking or analytics SDKs',
                      color: AppColors.kCyan,
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 400.ms)
                  .slideY(begin: 0.1, curve: Curves.easeOutCubic),

              const SizedBox(height: AppSpacing.lg),

              // Terms checkbox
              _ConsentCheckbox(
                checked: _termsChecked,
                onChanged: (v) => setState(() => _termsChecked = v ?? false),
                label: 'I agree to the ',
                linkText: 'Terms & Conditions',
                onLinkTap: () => setState(() => _showingTerms = !_showingTerms),
                borderColor: borderColor,
                cardColor: cardColor,
                textColor: textColor,
                isDark: isDark,
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 400.ms)
                  .slideY(begin: 0.08, curve: Curves.easeOutCubic),

              // Terms expandable
              if (_showingTerms)
                _ExpandableText(
                  text: LegalText.termsAndConditions,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  isDark: isDark,
                ),

              const SizedBox(height: AppSpacing.sm),

              // Privacy checkbox
              _ConsentCheckbox(
                checked: _privacyChecked,
                onChanged: (v) => setState(() => _privacyChecked = v ?? false),
                label: 'I agree to the ',
                linkText: 'Privacy Policy',
                onLinkTap: () =>
                    setState(() => _showingPrivacy = !_showingPrivacy),
                borderColor: borderColor,
                cardColor: cardColor,
                textColor: textColor,
                isDark: isDark,
              )
                  .animate()
                  .fadeIn(delay: 550.ms, duration: 400.ms)
                  .slideY(begin: 0.08, curve: Curves.easeOutCubic),

              // Privacy expandable
              if (_showingPrivacy)
                _ExpandableText(
                  text: LegalText.privacyPolicy,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  isDark: isDark,
                ),

              const Spacer(),

              // Accept button
              AnimatedOpacity(
                opacity: _canProceed ? 1.0 : 0.4,
                duration: AppDurations.fast,
                child: Container(
                  decoration: BoxDecoration(
                    gradient:
                        _canProceed ? AppColors.primaryGradient : null,
                    color: _canProceed ? null : AppColors.kTextMuted,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: _canProceed ? AppShadows.glowViolet : null,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _canProceed ? _acceptAndContinue : null,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.checkCircle,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Accept & Continue',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 400.ms),

              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isDark
                  ? AppColors.kTextSecondary
                  : AppColors.lightTextSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _ConsentCheckbox extends StatelessWidget {
  final bool checked;
  final ValueChanged<bool?> onChanged;
  final String label;
  final String linkText;
  final VoidCallback onLinkTap;
  final Color borderColor;
  final Color cardColor;
  final Color textColor;
  final bool isDark;

  const _ConsentCheckbox({
    required this.checked,
    required this.onChanged,
    required this.label,
    required this.linkText,
    required this.onLinkTap,
    required this.borderColor,
    required this.cardColor,
    required this.textColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
            color: borderColor.withValues(alpha: isDark ? 0.3 : 0.5)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: checked,
              onChanged: onChanged,
              activeColor: AppColors.kViolet,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: GestureDetector(
              onTap: onLinkTap,
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: textColor, fontSize: 13),
                  children: [
                    TextSpan(text: label),
                    TextSpan(
                      text: linkText,
                      style: const TextStyle(
                        color: AppColors.kViolet,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Icon(
            LucideIcons.chevronDown,
            size: 16,
            color: isDark ? AppColors.kTextMuted : AppColors.lightTextMuted,
          ),
        ],
      ),
    );
  }
}

class _ExpandableText extends StatelessWidget {
  final String text;
  final Color cardColor;
  final Color borderColor;
  final bool isDark;

  const _ExpandableText({
    required this.text,
    required this.cardColor,
    required this.borderColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
            color: borderColor.withValues(alpha: isDark ? 0.3 : 0.5)),
      ),
      child: SingleChildScrollView(
        child: Text(
          text,
          style: TextStyle(
            color: isDark
                ? AppColors.kTextSecondary
                : AppColors.lightTextSecondary,
            fontSize: 12,
            height: 1.6,
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 200.ms)
        .slideY(begin: -0.05, curve: Curves.easeOutCubic);
  }
}
