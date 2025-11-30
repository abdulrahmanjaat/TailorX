import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/helpers/validators.dart';
import '../../../core/theme/app_buttons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_inputs.dart';
import '../../../shared/services/snackbar_service.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/international_phone_field.dart';
import '../controllers/profile_controller.dart';
import '../models/profile_model.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _shopNameController;
  late final TextEditingController _phoneController;
  final _phoneFieldKey = GlobalKey<InternationalPhoneFieldState>();
  final _imagePicker = ImagePicker();
  File? _profileImage;
  bool _isLoading = false;
  bool _hasLoadedProfile = false;

  @override
  void initState() {
    super.initState();
    // Initialize with default values, will be updated when profile loads
    _nameController = TextEditingController();
    _shopNameController = TextEditingController();
    _phoneController = TextEditingController();
  }

  void _loadProfileData(ProfileModel profile) {
    if (!_hasLoadedProfile) {
      _nameController.text = profile.name;
      _shopNameController.text = profile.shopName;
      _phoneController.text = profile.phone;
      if (profile.profileImagePath != null) {
        final imageFile = File(profile.profileImagePath!);
        if (imageFile.existsSync()) {
          _profileImage = imageFile;
        }
      }
      _hasLoadedProfile = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shopNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Get full phone number with country code from the phone field
      final phone =
          _phoneFieldKey.currentState?.getFullPhoneNumber() ??
          _phoneController.text.trim();

      final profile = ProfileModel(
        name: _nameController.text.trim(),
        shopName: _shopNameController.text.trim(),
        phone: phone,
        profileImagePath: _profileImage?.path,
      );

      await ref.read(profileProvider.notifier).updateProfile(profile);

      if (mounted) {
        SnackbarService.showSuccess(
          context,
          message: 'Profile updated successfully',
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(context, message: 'Error saving profile: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    _loadProfileData(profile);

    return AppScaffold(
      title: 'Edit Profile',
      padding: const EdgeInsets.all(AppSizes.lg),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.primary.withValues(
                        alpha: 0.12,
                      ),
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? const Icon(
                              Icons.person,
                              size: 56,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primary,
                          child: const Icon(
                            Icons.camera_alt,
                            color: AppColors.background,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.xl),
              AppInputField(
                controller: _nameController,
                labelText: 'Owner Name',
                hintText: 'Enter your name',
                prefix: const Icon(Icons.person_outline),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Name is required' : null,
              ),
              const SizedBox(height: AppSizes.md),
              AppInputField(
                controller: _shopNameController,
                labelText: 'Shop/Studio Name',
                hintText: 'Enter shop name',
                prefix: const Icon(Icons.store_outlined),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Shop name is required' : null,
              ),
              const SizedBox(height: AppSizes.md),
              InternationalPhoneField(
                key: _phoneFieldKey,
                controller: _phoneController,
                labelText: 'Phone Number',
                hintText: '1234567890',
                validator: (value) => Validators.phone(value),
              ),
              const SizedBox(height: AppSizes.xl),
              AppButton(
                label: 'Save Changes',
                onPressed: _isLoading ? null : _saveProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
