import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../utils/constants.dart';

/// Reusable text input field with animated focus border.
/// Border morphs from rgba(255,255,255,0.1) to kViolet on focus.
class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool autofocus;
  final int maxLines;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.maxLines = 1,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.kTextPrimary : AppColors.lightTextPrimary;
    final hintColor = isDark ? AppColors.kTextMuted : AppColors.lightTextMuted;
    final fillColor = isDark ? AppColors.kSurface : AppColors.lightCardAlt;

    return Focus(
      onFocusChange: (focused) => setState(() => _hasFocus = focused),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(
            color: _hasFocus
                ? AppColors.kViolet
                : (isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.lightBorder),
            width: _hasFocus ? 2 : 1,
          ),
        ),
        child: TextFormField(
          controller: widget.controller,
          obscureText: _obscured,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          autofocus: widget.autofocus,
          maxLines: widget.maxLines,
          style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w500),
          cursorColor: AppColors.kViolet,
          decoration: InputDecoration(
            hintText: widget.hintText,
            labelText: widget.labelText,
            hintStyle: TextStyle(color: hintColor, fontWeight: FontWeight.w400),
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: _hasFocus ? AppColors.kViolet : AppColors.kTextMuted, size: 20)
                : null,
            suffixIcon: widget.obscureText
                ? GestureDetector(
                    onTap: () => setState(() => _obscured = !_obscured),
                    child: Icon(
                      _obscured ? LucideIcons.eyeOff : LucideIcons.eye,
                      color: hintColor,
                      size: 20,
                    ),
                  )
                : widget.suffixIcon,
            filled: true,
            fillColor: fillColor,
            // Remove all borders from the TextFormField itself —
            // the parent AnimatedContainer handles the border animation.
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: const BorderSide(color: AppColors.kPink, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
              borderSide: const BorderSide(color: AppColors.kPink, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md + 2),
          ),
        ),
      ),
    );
  }
}
