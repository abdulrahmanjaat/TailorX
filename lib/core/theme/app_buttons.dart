import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.imageIcon,
    this.fullWidth = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderWidth,
    this.boxShadow,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final String? imageIcon;
  final bool fullWidth;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? borderWidth;
  final List<BoxShadow>? boxShadow;

  /// Gradient matching the app bar
  static Gradient get gradient => LinearGradient(
    colors: [AppColors.primary, AppColors.secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  Color get _foregroundColor => textColor ?? AppColors.background;

  @override
  Widget build(BuildContext context) {
    final effectiveLabel = Text(
      label,
      style: AppTextStyles.bodyLarge.copyWith(
        color: _foregroundColor,
        fontWeight: FontWeight.w700,
        fontSize: 17,
        letterSpacing: 0.2,
      ),
      textAlign: TextAlign.center,
      softWrap: true,
    );

    final child = isLoading
        ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_foregroundColor),
              strokeWidth: 2.5,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (imageIcon != null) ...[
                Image.asset(
                  imageIcon!,
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: AppSizes.sm),
              ] else if (icon != null) ...[
                Icon(icon, size: 20, color: _foregroundColor),
                const SizedBox(width: AppSizes.sm),
              ],
              Flexible(child: effectiveLabel),
            ],
          );

    final button = Container(
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: backgroundColor == null ? gradient : null,
        borderRadius: BorderRadius.circular(100),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth ?? 1.0)
            : null,
        boxShadow: boxShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(100),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.lg,
              vertical: AppSizes.md,
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonWidth = constraints.maxWidth > 382
            ? 382.0
            : constraints.maxWidth;
        return SizedBox(width: buttonWidth, child: button);
      },
    );
  }
}
