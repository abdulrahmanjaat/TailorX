import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/custom_card.dart';
import '../models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final NotificationModel notification;
  final VoidCallback onTap;

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.customerAdded:
        return Icons.person_add;
      case NotificationType.measurementSaved:
        return Icons.straighten;
      case NotificationType.orderCreated:
        return Icons.receipt_long;
      case NotificationType.orderStatusUpdated:
        return Icons.check_circle;
      case NotificationType.fittingDateAssigned:
        return Icons.event;
      case NotificationType.deliveryDateAssigned:
        return Icons.local_shipping;
    }
  }

  Color _getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.customerAdded:
        return AppColors.success;
      case NotificationType.measurementSaved:
        return AppColors.primary;
      case NotificationType.orderCreated:
        return AppColors.secondary;
      case NotificationType.orderStatusUpdated:
        return AppColors.success;
      case NotificationType.fittingDateAssigned:
        return AppColors.accent;
      case NotificationType.deliveryDateAssigned:
        return AppColors.primary;
    }
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getIconForType(notification.type);
    final color = _getColorForType(notification.type);

    return CustomCard(
      padding: const EdgeInsets.all(AppSizes.md),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with background
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: AppSizes.iconMd,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: notification.isRead
                              ? FontWeight.w500
                              : FontWeight.w700,
                          color: notification.isRead
                              ? AppColors.dark.withValues(alpha: 0.7)
                              : AppColors.dark,
                        ),
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  notification.message,
                  style: AppTextStyles.bodyRegular.copyWith(
                    color: AppColors.dark.withValues(alpha: 0.6),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  _formatTimestamp(notification.createdAt),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.dark.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

