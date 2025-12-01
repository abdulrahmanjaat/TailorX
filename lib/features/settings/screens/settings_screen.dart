import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/helpers/validators.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_inputs.dart';
import '../../../shared/services/secure_storage_service.dart';
import '../../../shared/services/snackbar_service.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../auth/services/auth_service.dart';
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
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
          onPressed: () async {
            try {
              final authRepository = ref.read(authRepositoryProvider);
              await authRepository.signOut();
              if (context.mounted) {
                SnackbarService.showSuccess(
                  context,
                  message: 'Logged out successfully',
                );
                context.go(AppRoutes.onboarding);
              }
            } catch (e) {
              if (context.mounted) {
                SnackbarService.showError(
                  context,
                  message: 'Error logging out: ${e.toString()}',
                );
              }
            }
          },
        ),
      ],
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
          const SizedBox(height: AppSizes.xl),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Danger Zone',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              CustomCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.delete_forever_outlined,
                      color: AppColors.error,
                    ),
                  ),
                  title: Text(
                    'Delete Account',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                  subtitle: Text(
                    'Permanently delete your account and all data',
                    style: AppTextStyles.bodyRegular.copyWith(
                      color: AppColors.dark.withValues(alpha: 0.6),
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showDeleteAccountDialog(context, ref),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => _DeleteAccountDialog(
        onDelete: (email, password) async {
          Navigator.of(dialogContext).pop();
          await _deleteAccount(context, ref, email, password);
        },
      ),
    );
  }

  Future<void> _deleteAccount(
    BuildContext context,
    WidgetRef ref,
    String email,
    String password,
  ) async {
    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.deleteAccount(email: email, password: password);

      if (context.mounted) {
        SnackbarService.showSuccess(
          context,
          message: 'Account deleted successfully',
        );
        context.go(AppRoutes.onboarding);
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarService.showError(
          context,
          message: e.toString().replaceAll('Exception: ', ''),
        );
      }
    }
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

class _DeleteAccountDialog extends ConsumerStatefulWidget {
  const _DeleteAccountDialog({required this.onDelete});

  final Future<void> Function(String email, String password) onDelete;

  @override
  ConsumerState<_DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<_DeleteAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final email = await SecureStorageService.instance.getUserEmail();
    if (email != null && mounted) {
      _emailController.text = email;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _verifyAndDelete() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Verify credentials by attempting re-authentication
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.reauthenticate(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // If re-authentication succeeds, proceed with deletion
      if (mounted) {
        await widget.onDelete(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.error),
          const SizedBox(width: AppSizes.sm),
          const Text('Delete Account'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'To confirm account deletion, please enter your credentials:',
                style: AppTextStyles.bodyRegular,
              ),
              const SizedBox(height: AppSizes.lg),
              AppInputField(
                labelText: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
                prefix: Icon(
                  Icons.mail_outline,
                  color: AppColors.dark.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              AppInputField(
                labelText: 'Password',
                controller: _passwordController,
                obscureText: _obscurePassword,
                validator: (value) =>
                    Validators.requiredField(value, fieldName: 'Password'),
                prefix: Icon(
                  Icons.lock_outline,
                  color: AppColors.dark.withValues(alpha: 0.5),
                ),
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.dark.withValues(alpha: 0.5),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: AppSizes.md),
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: AppTextStyles.bodyRegular.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSizes.md),
              Text(
                'Warning: This action cannot be undone. All your data will be permanently deleted.',
                style: AppTextStyles.caption.copyWith(color: AppColors.error),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.dark),
          ),
        ),
        TextButton(
          onPressed: _isLoading ? null : _verifyAndDelete,
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.error),
                  ),
                )
              : Text(
                  'Delete Account',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }
}
