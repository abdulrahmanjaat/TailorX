import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/custom_card.dart';
import '../models/customer_model.dart';

class CustomerCard extends StatelessWidget {
  const CustomerCard({super.key, required this.customer, required this.onTap});

  final CustomerModel customer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(AppSizes.lg),
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
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
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer.name, style: AppTextStyles.titleLarge),
                const SizedBox(height: AppSizes.xs),
                Row(
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      size: AppSizes.iconSm,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSizes.xs),
                    Text(customer.phone, style: AppTextStyles.bodyRegular),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: AppSizes.iconSm,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
