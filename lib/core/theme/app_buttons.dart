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

  Gradient get _backgroundGradient {
    // All buttons use the same gradient as app bar
    return LinearGradient(
      colors: [AppColors.primary, AppColors.secondary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Color get _foregroundColor {
    // All buttons use white text on gradient background
    return AppColors.background;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveLabel = Text(
      label,
      style: AppTextStyles.button(isSmall).copyWith(color: _foregroundColor),
      textAlign: TextAlign.center,
      softWrap: true,
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
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppSizes.iconSm, color: _foregroundColor),
                const SizedBox(width: AppSizes.sm),
              ],
              Flexible(child: effectiveLabel),
            ],
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonWidth = constraints.maxWidth > 382
            ? 382.0
            : constraints.maxWidth;
        return SizedBox(
          width: buttonWidth,
          height: 48,
          child: Container(
            decoration: BoxDecoration(
              gradient: _backgroundGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isLoading ? null : onPressed,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmall ? AppSizes.md : AppSizes.lg,
                  ),
                  child: Center(child: child),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
