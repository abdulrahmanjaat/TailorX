import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_buttons.dart';
import '../../../core/theme/app_inputs.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/custom_card.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordSheet extends ConsumerStatefulWidget {
  const ForgotPasswordSheet({super.key});

  @override
  ConsumerState<ForgotPasswordSheet> createState() =>
      _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends ConsumerState<ForgotPasswordSheet> {
  Future<void> _handleNext() async {
    final controller = ref.read(forgotPasswordControllerProvider.notifier);
    final error = await controller.next();
    if (!mounted) return;
    if (error != null) {
      ToastService.show(context, message: error, isError: true);
      return;
    }
    final latest = ref.read(forgotPasswordControllerProvider);
    if (latest.completed) {
      Navigator.of(context).pop();
      ToastService.show(context, message: 'Password updated');
      controller.resetFlow();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordControllerProvider);
    final controller = ref.read(forgotPasswordControllerProvider.notifier);

    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      initialChildSize: 0.65,
      builder: (context, controllerScroll) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: controllerScroll,
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                Text('Reset access', style: AppTextStyles.headlineLarge),
                const SizedBox(height: AppSizes.sm),
                Row(
                  children: ForgotPasswordStep.values.map((step) {
                    final isActive = state.step.index >= step.index;
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.teal : Colors.black12,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSizes.lg),
                CustomCard(
                  child: Column(
                    children: [
                      if (state.step == ForgotPasswordStep.email)
                        AppInputField(
                          labelText: 'Account email',
                          hintText: 'studio@tailorx.com',
                          keyboardType: TextInputType.emailAddress,
                          onChanged: controller.updateEmail,
                        )
                      else if (state.step == ForgotPasswordStep.verify)
                        AppInputField(
                          labelText: '6-digit code',
                          hintText: '000000',
                          keyboardType: TextInputType.number,
                          onChanged: controller.updateCode,
                        )
                      else
                        AppInputField(
                          labelText: 'New password',
                          hintText: '••••••••',
                          obscureText: true,
                          onChanged: controller.updatePassword,
                        ),
                      const SizedBox(height: AppSizes.lg),
                      Row(
                        children: [
                          if (state.step != ForgotPasswordStep.email)
                            Expanded(
                              child: AppButton(
                                label: 'Back',
                                type: AppButtonType.secondary,
                                isSmall: true,
                                onPressed: controller.previous,
                              ),
                            ),
                          if (state.step != ForgotPasswordStep.email)
                            const SizedBox(width: AppSizes.md),
                          Expanded(
                            child: AppButton(
                              label: state.step == ForgotPasswordStep.reset
                                  ? 'Finish'
                                  : 'Continue',
                              onPressed: state.isLoading ? null : _handleNext,
                              isLoading: state.isLoading,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
