import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          error: AppColors.error,
        ).copyWith(
          onPrimary: AppColors.background,
          onSecondary: AppColors.dark,
          onSurface: AppColors.dark,
          onError: AppColors.background,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: AppTextStyles.toTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.dark,
        elevation: 0,
        titleTextStyle: AppTextStyles.titleLarge,
      ),
      inputDecorationTheme: const InputDecorationTheme().copyWith(
        filled: true,
        fillColor: AppColors.surface,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.dark,
        contentTextStyle: AppTextStyles.bodyRegular.copyWith(
          color: AppColors.background,
        ),
      ),
    );
  }
}
