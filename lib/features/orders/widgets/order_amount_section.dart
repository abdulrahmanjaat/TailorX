import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/custom_card.dart';

class OrderAmountSection extends StatelessWidget {
  const OrderAmountSection({
    super.key,
    required this.total,
    required this.advance,
    required this.remaining,
  });

  final double total;
  final double advance;
  final double remaining;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Amount Details', style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSizes.md),
          _AmountRow(label: 'Total Amount', amount: total),
          const SizedBox(height: AppSizes.sm),
          _AmountRow(label: 'Advance Paid', amount: advance),
          const Divider(height: AppSizes.xl),
          _AmountRow(
            label: 'Remaining',
            amount: remaining,
            isBold: true,
            textColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.amount,
    this.isBold = false,
    this.textColor,
  });

  final String label;
  final double amount;
  final bool isBold;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                )
              : AppTextStyles.bodyRegular,
        ),
        Text(
          'Rs. ${amount.toStringAsFixed(0)}',
          style: (isBold ? AppTextStyles.bodyLarge : AppTextStyles.bodyRegular)
              .copyWith(
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: textColor ?? AppColors.dark,
              ),
        ),
      ],
    );
  }
}
