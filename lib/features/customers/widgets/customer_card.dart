import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/services/phone_service.dart';
import '../../../shared/services/snackbar_service.dart';
import '../../../shared/widgets/custom_card.dart';
import '../models/customer_model.dart';

class CustomerCard extends StatelessWidget {
  const CustomerCard({super.key, required this.customer, required this.onTap});

  final CustomerModel customer;
  final VoidCallback onTap;

  Future<void> _handlePhoneTap(BuildContext context) async {
    try {
      await PhoneService.instance.openWhatsAppOrSMS(customer.phone);
      if (context.mounted) {
        SnackbarService.showInfo(context, message: 'Opening messaging app...');
      }
    } catch (e) {
      if (context.mounted) {
        final errorMessage = e.toString().contains('permission')
            ? 'SMS permission denied. Please grant permission in app settings.'
            : 'Unable to open messaging app. Please try again.';
        SnackbarService.showError(context, message: errorMessage);
      }
      print('Error opening WhatsApp/SMS: $e');
    }
  }

  Future<void> _handleCall(BuildContext context) async {
    try {
      await PhoneService.instance.makeCall(customer.phone);
      if (context.mounted) {
        SnackbarService.showInfo(context, message: 'Opening phone dialer...');
      }
    } catch (e) {
      if (context.mounted) {
        final errorMessage = e.toString().contains('permission')
            ? 'Phone permission denied. Please grant permission in app settings.'
            : 'Unable to make call. Please try again.';
        SnackbarService.showError(context, message: errorMessage);
      }
      print('Error making call: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Row(
        children: [
          GestureDetector(
            onTap: onTap,
            child: CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              child: Text(
                customer.name.substring(0, 1),
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    customer.name,
                    style: AppTextStyles.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSizes.xs),
                  GestureDetector(
                    onTap: () => _handlePhoneTap(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          size: AppSizes.iconSm,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSizes.xs),
                        Flexible(
                          child: Text(
                            customer.phone,
                            style: AppTextStyles.bodyRegular.copyWith(
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSizes.xs),
          // Call button - compact
          InkWell(
            onTap: () => _handleCall(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(AppSizes.sm),
              child: const Icon(
                Icons.call,
                color: AppColors.primary,
                size: AppSizes.iconSm,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.xs),
          // Message button (WhatsApp/SMS) - compact
          InkWell(
            onTap: () => _handlePhoneTap(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(AppSizes.sm),
              child: const Icon(
                Icons.message,
                color: AppColors.primary,
                size: AppSizes.iconSm,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.xs),
          // Arrow for detail view
          GestureDetector(
            onTap: onTap,
            child: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: AppSizes.iconSm,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
