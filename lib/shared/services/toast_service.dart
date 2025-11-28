import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ToastService {
  ToastService._();

  static OverlayEntry? _currentEntry;

  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
  }) {
    _currentEntry?.remove();
    final overlay = Overlay.of(context, rootOverlay: true);

    final entry = OverlayEntry(
      builder: (context) {
        final topPadding = MediaQuery.of(context).padding.top + 16;
        return Positioned(
          top: topPadding,
          left: 16,
          right: 16,
          child: _ToastBanner(message: message, isError: isError),
        );
      },
    );

    overlay.insert(entry);
    _currentEntry = entry;

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (_currentEntry == entry) {
        _currentEntry?.remove();
        _currentEntry = null;
      }
    });
  }
}

class _ToastBanner extends StatelessWidget {
  const _ToastBanner({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isError
              ? AppColors.error
              : AppColors.dark.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          message,
          style: AppTextStyles.bodyRegular.copyWith(
            color: AppColors.background,
          ),
        ),
      ),
    );
  }
}
