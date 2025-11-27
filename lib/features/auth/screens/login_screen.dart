import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/helpers/validators.dart';
import '../../../core/theme/app_buttons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_inputs.dart';
import '../../../shared/widgets/auth_shell.dart';
import '../../../shared/widgets/custom_card.dart';
import '../controllers/login_controller.dart';
import '../widgets/forgot_password_sheet.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final controller = ref.read(loginControllerProvider.notifier);
    final error = await controller.submit();
    if (!mounted) return;
    if (error != null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
      return;
    }
    context.go(AppRoutes.home);
  }

  void _openForgotPassword() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ForgotPasswordSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);
    final controller = ref.read(loginControllerProvider.notifier);

    final formCard = CustomCard(
      padding: const EdgeInsets.all(AppSizes.xl),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Login', style: AppTextStyles.headlineLarge),
            const SizedBox(height: AppSizes.xs),
            Text(
              'Access your atelier workspace.',
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: AppSizes.xl),
            AppInputField(
              labelText: 'Email',
              hintText: 'team@tailorx.com',
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
              onChanged: controller.updateEmail,
              prefix: const Icon(Icons.mail_outline),
            ),
            const SizedBox(height: AppSizes.md),
            AppInputField(
              labelText: 'Password',
              hintText: '••••••••',
              obscureText: true,
              validator: (value) =>
                  Validators.requiredField(value, fieldName: 'Password'),
              onChanged: controller.updatePassword,
              prefix: const Icon(Icons.lock_outline),
            ),
            const SizedBox(height: AppSizes.sm),
            Row(
              children: [
                GestureDetector(
                  onTap: _openForgotPassword,
                  child: Text(
                    'Forgot password?',
                    style: AppTextStyles.bodyRegular.copyWith(
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.primary,
                    ),
                  ),
                ),
                const Spacer(),
                AppButton(
                  label: 'Login',
                  onPressed: state.isLoading ? null : _submit,
                  isSmall: true,
                  isLoading: state.isLoading,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            AppButton(
              label: 'Create account',
              type: AppButtonType.secondary,
              onPressed: () => context.go(AppRoutes.signup),
            ),
          ],
        ),
      ),
    );

    return AuthShell(
      subtitle: 'Member access',
      child: SingleChildScrollView(child: formCard),
    );
  }
}
