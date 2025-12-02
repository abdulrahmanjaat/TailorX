import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/services/snackbar_service.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../auth/services/auth_service.dart';
import '../controllers/profile_controller.dart';
import '../models/profile_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _imagePicker = ImagePicker();
  bool _isUploadingImage = false;

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() => _isUploadingImage = true);

        final imageFile = File(image.path);
        final currentProfile = ref.read(profileProvider).value;

        if (currentProfile == null) {
          if (mounted) {
            SnackbarService.showError(
              context,
              message: 'Profile not loaded. Please try again.',
            );
          }
          return;
        }

        try {
          // Upload image and update profile
          await ref
              .read(profileProvider.notifier)
              .updateProfile(currentProfile, imageFile: imageFile);

          if (mounted) {
            SnackbarService.showSuccess(
              context,
              message: 'Profile image updated successfully',
            );
          }
        } catch (e) {
          if (mounted) {
            SnackbarService.showError(
              context,
              message: 'Failed to upload image: $e',
            );
          }
        } finally {
          if (mounted) {
            setState(() => _isUploadingImage = false);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(context, message: 'Error picking image: $e');
        setState(() => _isUploadingImage = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.signOut();
      if (mounted) {
        SnackbarService.showSuccess(
          context,
          message: 'Logged out successfully',
        );
        context.go(AppRoutes.onboarding);
      }
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(
          context,
          message: 'Error logging out: ${e.toString()}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'My Profile',
      padding: EdgeInsets.only(top: 10),
      body: ref
          .watch(profileProvider)
          .when(
            data: (profile) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileHeader(
                  profile: profile,
                  isUploading: _isUploadingImage,
                  onCameraTap: _pickImage,
                ),
                const SizedBox(height: AppSizes.sm),
                _AccountSection(
                  title: 'Account',
                  items: [
                    _ProfileMenuItem(
                      icon: Icons.settings,
                      title: 'Settings',
                      onTap: () => context.push(AppRoutes.settings),
                    ),
                    _ProfileMenuItem(
                      icon: Icons.notifications,
                      title: 'Notification',
                      onTap: () => context.push(AppRoutes.notifications),
                    ),
                    _ProfileMenuItem(
                      icon: Icons.history,
                      title: 'Order History',
                      onTap: () => context.push(AppRoutes.ordersList),
                    ),
                    _ProfileMenuItem(
                      icon: Icons.privacy_tip,
                      title: 'Privacy & Policy',
                      onTap: () => context.push(AppRoutes.termsPrivacy),
                    ),
                    _ProfileMenuItem(
                      icon: Icons.description,
                      title: 'Terms & Conditions',
                      onTap: () => context.push(AppRoutes.termsPrivacy),
                    ),
                    _ProfileMenuItem(
                      icon: Icons.logout,
                      title: 'Log Out',
                      onTap: _handleLogout,
                      isDestructive: true,
                    ),
                  ],
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error loading profile: $error'),
                  const SizedBox(height: AppSizes.md),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(profileProvider.notifier).refreshProfile(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.profile,
    required this.isUploading,
    required this.onCameraTap,
  });

  final ProfileModel profile;
  final bool isUploading;
  final VoidCallback onCameraTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg,
          vertical: AppSizes.sm,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  backgroundImage: profile.imageUrl != null
                      ? NetworkImage(profile.imageUrl!)
                      : null,
                  child: profile.imageUrl == null
                      ? const Icon(
                          Icons.person,
                          size: 48,
                          color: AppColors.primary,
                        )
                      : isUploading
                      ? const CircularProgressIndicator(
                          color: AppColors.primary,
                        )
                      : null,
                ),
                // Camera icon for picking image
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: isUploading ? null : onCameraTap,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.background,
                          width: 2,
                        ),
                      ),
                      child: isUploading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.background,
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt,
                              color: AppColors.background,
                              size: 18,
                            ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              profile.name.isNotEmpty ? profile.name : 'Your Name',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              profile.email.isNotEmpty ? profile.email : 'abc@gmail.com',
              style: AppTextStyles.bodyRegular.copyWith(
                color: AppColors.dark.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection({required this.title, required this.items});

  final String title;
  final List<_ProfileMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          ...items,
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isDestructive ? AppColors.error : AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isDestructive ? AppColors.error : AppColors.dark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.dark.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
