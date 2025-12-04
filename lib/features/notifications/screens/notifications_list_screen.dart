import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_buttons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/services/snackbar_service.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../providers/notifications_providers.dart';
import '../widgets/notification_tile.dart';

class NotificationsListScreen extends ConsumerWidget {
  const NotificationsListScreen({super.key});

  Future<void> _markAsRead(
    BuildContext context,
    WidgetRef ref,
    String notificationId,
  ) async {
    try {
      final repository = ref.read(notificationsFirestoreRepositoryProvider);
      await repository.markAsRead(notificationId);
    } catch (e) {
      if (context.mounted) {
        SnackbarService.showError(
          context,
          message: 'Failed to mark notification as read: $e',
        );
      }
    }
  }

  Future<void> _markAllAsRead(BuildContext context, WidgetRef ref) async {
    try {
      final repository = ref.read(notificationsFirestoreRepositoryProvider);
      await repository.markAllAsRead();
      if (context.mounted) {
        SnackbarService.showSuccess(
          context,
          message: 'All notifications marked as read',
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarService.showError(
          context,
          message: 'Failed to mark all as read: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsStreamProvider);

    return AppScaffold(
      title: 'Notifications',
      actions: [
        notificationsAsync.when(
          data: (notifications) {
            final hasUnread = notifications.any((n) => !n.isRead);
            if (!hasUnread) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Mark all as read',
              onPressed: () => _markAllAsRead(context, ref),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),
      ],
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: AppColors.dark.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    'No notifications yet',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.dark.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    'You\'ll see notifications here when something happens',
                    style: AppTextStyles.bodyRegular.copyWith(
                      color: AppColors.dark.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.lg),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child: NotificationTile(
                  notification: notification,
                  onTap: () {
                    // Mark as read when tapped
                    if (!notification.isRead) {
                      _markAsRead(context, ref, notification.id);
                    }

                    // Navigate to order detail if orderId exists
                    if (notification.orderId != null) {
                      context.push(
                        '${AppRoutes.orderDetail}/${notification.orderId}',
                      );
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: AppSizes.md),
              Text(
                'Error loading notifications',
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: AppSizes.xs),
              Text(
                error.toString(),
                style: AppTextStyles.bodyRegular,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.md),
              AppButton(
                label: 'Retry',
                onPressed: () => ref.refresh(notificationsStreamProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
