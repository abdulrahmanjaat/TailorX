import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ToastService {
  ToastService._();

  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: isError ? AppColors.error : AppColors.dark,
        content: Text(
          message,
          style: AppTextStyles.bodyRegular.copyWith(
            color: AppColors.background,
          ),
        ),
      ),
    );
  }
}
