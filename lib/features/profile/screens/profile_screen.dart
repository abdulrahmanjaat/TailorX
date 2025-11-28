import 'dart:io';

import 'package:flutter/material.dart';
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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileHeader(
              profileImage: _profileImage,
              onCameraTap: _pickImage,
            ),
            const SizedBox(height: AppSizes.lg),
            const _ProfileDetails(),
            const SizedBox(height: AppSizes.lg),
            AppButton(
              label: 'Edit Profile',
              onPressed: () => context.push(AppRoutes.settings),
            ),
            const SizedBox(height: AppSizes.md),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profileImage, required this.onCameraTap});

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
          Text('Ahsan Qureshi', style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSizes.xs),
          Text('TailorX Atelier · Karachi', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _ProfileDetails extends StatelessWidget {
  const _ProfileDetails();

  final info = const [
    ('Owner Name', 'Ahsan Qureshi'),
    ('Studio Name', 'TailorX Atelier'),
    ('Email', 'ahsan@tailorxstudio.com'),
    ('Phone', '+92 300 1234567'),
    ('Location', 'Karachi, Pakistan'),
    ('Specialty', 'Luxury couture · Bridal'),
  ];

  @override
  Widget build(BuildContext context) {
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
