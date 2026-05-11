import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Reusable text input field with consistent styling across all screens.
/// Replaces 5 duplicated _buildInputField() methods.
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

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final hintColor = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
    final fillColor = isDark ? AppColors.darkCardAlt : AppColors.lightCardAlt;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return TextFormField(
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
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: widget.hintText,
        labelText: widget.labelText,
        hintStyle: TextStyle(color: hintColor, fontWeight: FontWeight.w400),
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: AppColors.primary.withValues(alpha: 0.7), size: 20)
            : null,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscured ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: hintColor,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : widget.suffixIcon,
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: borderColor.withValues(alpha: 0.4), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md + 2),
      ),
    );
  }
}
