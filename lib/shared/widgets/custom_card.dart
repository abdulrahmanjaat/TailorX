import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_colors.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSizes.md),
    this.onTap,
    this.gradient,
    this.borderRadius = 18,
    this.boxShadow,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: padding,
      decoration: BoxDecoration(
        gradient:
            gradient ??
            LinearGradient(
              colors: [AppColors.surface, AppColors.surface],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.borderGray.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow:
            boxShadow ??
            [
              BoxShadow(
                color: AppColors.dark.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
      ),
      child: child,
    );

    if (onTap == null) return content;

    return GestureDetector(onTap: onTap, child: content);
  }
}
