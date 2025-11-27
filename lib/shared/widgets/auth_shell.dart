import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_scaffold.dart';
import 'aurora_background.dart';

class AuthShell extends StatelessWidget {
  const AuthShell({super.key, required this.child, this.subtitle});

  final Widget child;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: AuroraBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _BrandMark(subtitle: subtitle),
                    const Spacer(),
                    const _DateBadge(),
                  ],
                ),
                const SizedBox(height: AppSizes.lg),
                Container(
                  height: 2,
                  width: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({this.subtitle});

  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.85),
            boxShadow: [
              BoxShadow(
                color: AppColors.dark.withValues(alpha: 0.08),
                blurRadius: 18,
              ),
            ],
          ),
          child: Image.asset('assets/images/logo.png', height: 32, width: 32),
        ),
        const SizedBox(width: AppSizes.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TailorX', style: AppTextStyles.titleLarge),
            if (subtitle != null) Text(subtitle!, style: AppTextStyles.caption),
          ],
        ),
      ],
    );
  }
}

class _DateBadge extends StatelessWidget {
  const _DateBadge();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formatted = '${now.day}.${now.month}.${now.year}';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.5),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
      ),
      child: Text(formatted, style: AppTextStyles.caption),
    );
  }
}
