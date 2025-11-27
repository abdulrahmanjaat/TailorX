import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.dark,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: AppColors.dark,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.dark,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.dark,
  );

  static const TextStyle bodyRegular = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.dark,
  );

  static TextStyle button(bool isSmall) => TextStyle(
    fontSize: isSmall ? 14 : 16,
    fontWeight: FontWeight.w600,
    color: AppColors.background,
    letterSpacing: 0.4,
  );

  static const TextStyle input = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.dark,
  );

  static const TextStyle inputHint = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.dark,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.dark,
  );

  static TextTheme toTextTheme() {
    return const TextTheme(
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      titleLarge: titleLarge,
      bodyLarge: bodyLarge,
      bodyMedium: bodyRegular,
      bodySmall: caption,
      labelLarge: bodyRegular,
      labelSmall: caption,
    );
  }

  static EdgeInsets screenPadding = const EdgeInsets.symmetric(
    horizontal: AppSizes.md,
    vertical: AppSizes.sm,
  );
}
