import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../auth/widgets/forgot_password_sheet.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showChangePasswordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ForgotPasswordSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: 'Settings',
      padding: const EdgeInsets.all(AppSizes.lg),
      body: ListView(
        children: [
          _SettingsSection(
            title: 'Account',
            items: [
              _SettingsItem(
                Icons.person_outline,
                'Edit Profile',
                'Update tailor details',
                route: AppRoutes.editProfile,
              ),
              _SettingsItem(
                Icons.lock_outline,
                'Change Password',
                'Secure your account',
                onTap: () => _showChangePasswordSheet(context),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          const _SettingsSection(
            title: 'Privacy & Security',
            items: [
              _SettingsItem(
                Icons.privacy_tip_outlined,
                'Privacy Controls',
                'Manage data sharing',
              ),
              _SettingsItem(
                Icons.shield_outlined,
                'Permissions',
                'App & device access',
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          const _SettingsSection(
            title: 'App Preferences',
            items: [
              _SettingsItem(Icons.language, 'Language', 'English (US)'),
              _SettingsItem(Icons.dark_mode_outlined, 'Theme', 'Light'),
              _SettingsItem(
                Icons.notifications_outlined,
                'Notifications',
                'On',
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          const _SettingsSection(
            title: 'Support',
            items: [
              _SettingsItem(
                Icons.help_outline,
                'Help Center',
                'FAQs & tutorials',
              ),
              _SettingsItem(
                Icons.article_outlined,
                'Terms & Privacy',
                'Policies & compliance',
                route: AppRoutes.termsPrivacy,
              ),
              _SettingsItem(
                Icons.support_agent,
                'Contact Support',
                'We respond within 24h',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.items});

  final String title;
  final List<_SettingsItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.titleLarge),
        const SizedBox(height: AppSizes.md),
        CustomCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(items[i].icon, color: AppColors.primary),
                  ),
                  title: Text(
                    items[i].title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    items[i].subtitle,
                    style: AppTextStyles.bodyRegular.copyWith(
                      color: AppColors.dark.withValues(alpha: 0.6),
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap:
                      items[i].onTap ??
                      (items[i].route != null
                          ? () => context.push(items[i].route!)
                          : null),
                ),
                if (i != items.length - 1)
                  const Divider(indent: 72, endIndent: AppSizes.md),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsItem {
  const _SettingsItem(
    this.icon,
    this.title,
    this.subtitle, {
    this.route,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? route;
  final VoidCallback? onTap;
}
