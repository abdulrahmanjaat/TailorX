import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum SnackbarType { success, error, info }

class SnackbarService {
  SnackbarService._();

  /// Shows a success snackbar with green background
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      type: SnackbarType.success,
      duration: duration,
    );
  }

  /// Shows an error snackbar with red background
  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      type: SnackbarType.error,
      duration: duration,
    );
  }

  /// Shows an info snackbar with default background
  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      type: SnackbarType.info,
      duration: duration,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required SnackbarType type,
    required Duration duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _CustomSnackbarContent(message: message, type: type),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(
          left: AppSizes.md,
          right: AppSizes.md,
          bottom: AppSizes.lg,
        ),
        duration: duration,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class _CustomSnackbarContent extends StatelessWidget {
  const _CustomSnackbarContent({required this.message, required this.type});

  final String message;
  final SnackbarType type;

  Color get _backgroundColor {
    switch (type) {
      case SnackbarType.success:
        return AppColors.success;
      case SnackbarType.error:
        return AppColors.error;
      case SnackbarType.info:
        return AppColors.dark;
    }
  }

  IconData get _icon {
    switch (type) {
      case SnackbarType.success:
        return Icons.check_circle_outline;
      case SnackbarType.error:
        return Icons.error_outline;
      case SnackbarType.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.md,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(_icon, color: AppColors.background, size: 24),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyRegular.copyWith(
                color: AppColors.background,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
