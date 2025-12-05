import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/order_model.dart';

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.status});

  final OrderStatus status;

  Color get _backgroundColor {
    switch (status) {
      case OrderStatus.newOrder:
        return Colors.green.withValues(alpha: 0.15);
      case OrderStatus.inProgress:
        return Colors.orange.withValues(alpha: 0.15);
      case OrderStatus.completed:
        return Colors.red.withValues(alpha: 0.15);
    }
  }

  Color get _textColor {
    switch (status) {
      case OrderStatus.newOrder:
        return Colors.green;
      case OrderStatus.inProgress:
        return Colors.orange;
      case OrderStatus.completed:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.sm),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.caption.copyWith(
          color: _textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
