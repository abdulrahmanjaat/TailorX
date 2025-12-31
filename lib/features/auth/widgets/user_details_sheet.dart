import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/helpers/validators.dart';
import '../../../core/theme/app_buttons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_inputs.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/services/snackbar_service.dart';

class UserDetailsSheet extends StatefulWidget {
  const UserDetailsSheet({
    super.key,
    required this.initialName,
    required this.initialEmail,
    required this.onSubmit,
    this.initialShopName = '',
    this.initialPhone = '',
    this.initialCountryCode = 'PK',
  });

  final String initialName;
  final String initialEmail;
  final String initialShopName;
  final String initialPhone;
  final String initialCountryCode;
  final Future<void> Function({
    required String name,
    required String shopName,
    required String phone,
  })
  onSubmit;

  @override
  State<UserDetailsSheet> createState() => _UserDetailsSheetState();
}

class _UserDetailsSheetState extends State<UserDetailsSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _shopController = TextEditingController();
  final _phoneController = TextEditingController();
  PhoneNumber? _phoneNumber;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName;
    _shopController.text = widget.initialShopName;
    _phoneController.text = widget.initialPhone;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shopController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    try {
      final phone =
          _phoneNumber?.completeNumber ??
          (_phoneController.text.isNotEmpty
              ? _phoneController.text.trim()
              : '');

      await widget.onSubmit(
        name: _nameController.text.trim(),
        shopName: _shopController.text.trim(),
        phone: phone,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(
          context,
          message: e.toString().replaceAll('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSizes.md),
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.dark.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  Text(
                    'Complete your profile',
                    style: AppTextStyles.headlineMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    'We need a few more details to set up your workspace.',
                    style: AppTextStyles.bodyRegular.copyWith(
                      color: AppColors.dark.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: AppSizes.xl),
                  AppInputField(
                    labelText: 'Full name',
                    hintText: 'Your name',
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                        Validators.requiredField(value, fieldName: 'Full name'),
                    prefix: Icon(
                      Icons.person_outline,
                      color: AppColors.dark.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  AppInputField(
                    labelText: 'Shop / Studio',
                    hintText: 'TailorX',
                    controller: _shopController,
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                        Validators.requiredField(value, fieldName: 'Shop name'),
                    prefix: Icon(
                      Icons.store_outlined,
                      color: AppColors.dark.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  IntlPhoneField(
                    controller: _phoneController,
                    initialCountryCode: widget.initialCountryCode,
                    decoration: InputDecoration(
                      labelText: 'Phone number',
                      hintText: 'Enter phone number',
                      hintStyle: AppTextStyles.inputHint.copyWith(
                        color: AppColors.dark.withValues(alpha: 0.6),
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                        vertical: AppSizes.md,
                      ),
                      constraints: const BoxConstraints(minHeight: 56),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.borderGray,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.borderGray,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.error,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (phone) {
                      setState(() {
                        _phoneNumber = phone;
                      });
                    },
                    validator: (phone) =>
                        Validators.phone(phone?.completeNumber ?? ''),
                  ),
                  const SizedBox(height: AppSizes.xl),
                  AppButton(
                    label: 'Continue',
                    onPressed: _isSubmitting ? null : _submit,
                    isLoading: _isSubmitting,
                    fullWidth: true,
                  ),
                  const SizedBox(height: AppSizes.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
