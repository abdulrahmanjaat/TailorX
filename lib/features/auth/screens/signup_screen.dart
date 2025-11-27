import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/helpers/validators.dart';
import '../../../core/theme/app_buttons.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_inputs.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/auth_shell.dart';
import '../../../shared/widgets/custom_card.dart';
import '../controllers/signup_controller.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final controller = ref.read(signupControllerProvider.notifier);
    final error = await controller.submit();
    if (!mounted) return;
    if (error != null) {
      ToastService.show(context, message: error, isError: true);
      return;
    }
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signupControllerProvider);
    final controller = ref.read(signupControllerProvider.notifier);

    final formCard = CustomCard(
      padding: const EdgeInsets.all(AppSizes.xl),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create account', style: AppTextStyles.headlineLarge),
            const SizedBox(height: AppSizes.xs),
            Text(
              'Onboard your atelier in moments.',
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: AppSizes.xl),
            AppInputField(
              labelText: 'Full name',
              hintText: 'Avery Laurent',
              validator: (value) =>
                  Validators.requiredField(value, fieldName: 'Name'),
              onChanged: controller.updateName,
              prefix: const Icon(Icons.person_outline),
            ),
            const SizedBox(height: AppSizes.md),
            AppInputField(
              labelText: 'Shop / Studio',
              hintText: 'Maison Atelier',
              validator: (value) =>
                  Validators.requiredField(value, fieldName: 'Studio'),
              onChanged: controller.updateOrganization,
              prefix: const Icon(Icons.store_outlined),
            ),
            const SizedBox(height: AppSizes.md),
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
            const SizedBox(height: AppSizes.lg),
            AppButton(
              label: 'Create account',
              onPressed: state.isLoading ? null : _submit,
              isLoading: state.isLoading,
            ),
            const SizedBox(height: AppSizes.md),
            AppButton(
              label: 'Back to login',
              type: AppButtonType.secondary,
              onPressed: () => context.go(AppRoutes.login),
            ),
          ],
        ),
      ),
    );

    return AuthShell(
      subtitle: 'Studio onboarding',
      child: SingleChildScrollView(child: formCard),
    );
  }
}
