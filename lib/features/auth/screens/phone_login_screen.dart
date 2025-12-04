import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/helpers/validators.dart';
import '../../../core/theme/app_buttons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_inputs.dart';
import '../../../shared/services/secure_storage_service.dart';
import '../../../shared/services/snackbar_service.dart';
import '../../../shared/widgets/auth_shell.dart';
import '../services/auth_service.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  PhoneNumber? _phoneNumber;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _initialCountryCode;

  @override
  void initState() {
    super.initState();
    _loadCountryCode();
  }

  Future<void> _loadCountryCode() async {
    final countryCode = await SecureStorageService.instance.getCountryCode();
    if (mounted) {
      setState(() {
        _initialCountryCode = countryCode ?? 'PK';
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final phoneNumber =
          _phoneNumber?.completeNumber ?? _phoneController.text.trim();

      await authRepository.signIn(
        emailOrPhone: phoneNumber,
        password: _passwordController.text,
      );

      if (mounted) {
        SnackbarService.showSuccess(context, message: 'Welcome back!');
        context.go(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        SnackbarService.showError(context, message: errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      subtitle: 'Phone Login',
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Login with Phone',
                style: AppTextStyles.headlineLarge.copyWith(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: AppColors.dark,
                  letterSpacing: -1,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                'Enter your phone number and password to continue',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.dark.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w400,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: AppSizes.xxl + AppSizes.lg),
              Text(
                'Phone Number',
                style: AppTextStyles.bodyRegular.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSizes.xs),
              _initialCountryCode == null
                  ? const SizedBox(
                      height: 56,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : IntlPhoneField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        hintStyle: AppTextStyles.inputHint.copyWith(
                          color: AppColors.dark.withValues(alpha: 0.6),
                        ),
                        labelStyle: TextStyle(
                          color: AppColors.dark,
                          fontWeight: FontWeight.w500,
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
                      initialCountryCode: _initialCountryCode ?? 'PK',
                      onChanged: (phone) {
                        setState(() {
                          _phoneNumber = phone;
                        });
                      },
                      validator: (phone) {
                        if (phone == null || phone.number.isEmpty) {
                          return 'Phone number is required';
                        }
                        if (phone.number.length < 10) {
                          return 'Phone number must be at least 10 digits';
                        }
                        return null;
                      },
                    ),
              const SizedBox(height: AppSizes.lg),
              AppInputField(
                labelText: 'Password',
                hintText: 'Enter your password',
                controller: _passwordController,
                obscureText: _obscurePassword,
                validator: Validators.password,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  hintStyle: AppTextStyles.inputHint.copyWith(
                    color: AppColors.dark.withValues(alpha: 0.6),
                  ),
                  labelText: 'Password',
                  labelStyle: TextStyle(
                    color: AppColors.dark,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: AppColors.dark.withValues(alpha: 0.5),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.dark.withValues(alpha: 0.5),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
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
              ),
              const SizedBox(height: AppSizes.xxl),
              Center(
                child: AppButton(
                  label: 'Sign In',
                  onPressed: _isLoading ? null : _submit,
                  isLoading: _isLoading,
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: AppTextStyles.bodyRegular.copyWith(
                      color: AppColors.dark.withValues(alpha: 0.6),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.signup),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Sign up',
                      style: AppTextStyles.bodyRegular.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
