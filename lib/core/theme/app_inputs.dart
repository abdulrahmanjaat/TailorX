import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppInputField extends StatelessWidget {
  const AppInputField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefix,
    this.suffix,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.textInputAction,
    this.enabled = true,
    this.maxLines = 1,
    this.decoration,
    this.autofillHints,
  });

  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final Widget? prefix;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final bool enabled;
  final int maxLines;
  final InputDecoration? decoration;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      textInputAction: textInputAction,
      enabled: enabled,
      maxLines: maxLines,
      autofillHints: autofillHints,
      style: AppTextStyles.input.copyWith(
        color: AppColors.dark,
        fontWeight: FontWeight.w500,
      ),
      decoration:
          decoration ??
          InputDecoration(
            hintText: hintText,
            labelText: labelText,
            hintStyle: AppTextStyles.inputHint.copyWith(
              color: AppColors.dark.withValues(alpha: 0.6),
            ),
            labelStyle: TextStyle(
              color: AppColors.dark,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: prefix,
            suffixIcon: suffix,
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.md,
            ),
            constraints: const BoxConstraints(minHeight: 56),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.borderGray,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.borderGray,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
          ),
    );
  }
}
