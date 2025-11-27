import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class CustomCircularIndicator extends StatelessWidget {
  const CustomCircularIndicator({
    super.key,
    required this.progress,
    this.size = 120,
    this.label,
  });

  final double progress; // 0..1
  final double size;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0, 1).toDouble();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.surface.withValues(alpha: 0.2),
                  AppColors.surface.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
          Transform.rotate(
            angle: -math.pi / 2,
            child: SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                strokeWidth: 6,
                value: clampedProgress,
                backgroundColor: AppColors.surface.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${(clampedProgress * 100).round()}%',
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: AppSizes.xs),
              if (label != null) Text(label!, style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}
