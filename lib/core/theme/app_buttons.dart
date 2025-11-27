import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

enum AppButtonType { primary, secondary }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.isSmall = false,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isSmall;
  final bool isLoading;
  final IconData? icon;

  Color get _backgroundColor {
    switch (type) {
      case AppButtonType.secondary:
        return AppColors.surface;
      case AppButtonType.primary:
        return AppColors.primary;
    }
  }

  Color get _foregroundColor {
    switch (type) {
      case AppButtonType.secondary:
        return AppColors.dark;
      case AppButtonType.primary:
        return AppColors.background;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveLabel = Text(
      label,
      style: AppTextStyles.button(isSmall).copyWith(color: _foregroundColor),
    );

    final child = isLoading
        ? SizedBox(
            width: AppSizes.iconSm,
            height: AppSizes.iconSm,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_foregroundColor),
              strokeWidth: 2,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppSizes.iconSm, color: _foregroundColor),
                const SizedBox(width: AppSizes.sm),
              ],
              effectiveLabel,
            ],
          );

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: isSmall ? 44 : 52),
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: _backgroundColor,
          foregroundColor: _foregroundColor,
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? AppSizes.md : AppSizes.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.sm),
          ),
          elevation: 0,
        ),
        onPressed: isLoading ? null : onPressed,
        child: child,
      ),
    );
  }
}
