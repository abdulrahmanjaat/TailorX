import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_buttons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/services/snackbar_service.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/custom_card.dart';
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
  File? _profileImage;

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() => _profileImage = File(image.path));
      }
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(context, message: 'Error picking image: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Profile',
      padding: const EdgeInsets.all(AppSizes.lg),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
          onPressed: () async {
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
          },
        ),
      ],
      body: ref
          .watch(profileProvider)
          .when(
            data: (profile) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileHeader(
                  profile: profile,
                  profileImage: _profileImage,
                  onCameraTap: _pickImage,
                ),
                const SizedBox(height: AppSizes.lg),
                Expanded(
                  child: SingleChildScrollView(
                    child: _ProfileDetails(profile: profile),
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                Center(
                  child: AppButton(
                    label: 'Edit Profile',
                    onPressed: () => context.push(AppRoutes.settings),
                  ),
                ),
                const SizedBox(height: AppSizes.md),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error loading profile: $error'),
                  const SizedBox(height: AppSizes.md),
                  AppButton(
                    label: 'Retry',
                    onPressed: () =>
                        ref.read(profileProvider.notifier).refreshProfile(),
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
    required this.profileImage,
    required this.onCameraTap,
  });

  final ProfileModel profile;
  final File? profileImage;
  final VoidCallback onCameraTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                backgroundImage: profileImage != null
                    ? FileImage(profileImage!)
                    : null,
                child: profileImage == null
                    ? const Icon(
                        Icons.person,
                        size: 48,
                        color: AppColors.primary,
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onCameraTap,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary,
                    child: const Icon(
                      Icons.camera_alt,
                      color: AppColors.background,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            profile.name.isNotEmpty ? profile.name : 'User',
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            profile.shopName.isNotEmpty ? '${profile.shopName}' : 'TailorX',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _ProfileDetails extends StatelessWidget {
  const _ProfileDetails({required this.profile});

  final ProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final info = [
      ('Owner Name', profile.name.isNotEmpty ? profile.name : 'Not set'),
      (
        'Studio Name',
        profile.shopName.isNotEmpty ? profile.shopName : 'Not set',
      ),
      ('Email', profile.email.isNotEmpty ? profile.email : 'Not set'),
      ('Phone', profile.phone.isNotEmpty ? profile.phone : 'Not set'),
    ];

    return CustomCard(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: info
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(
                        item.$1,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.dark.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(item.$2, style: AppTextStyles.bodyLarge),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
