import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/custom_card.dart';
import '../controllers/notification_controller.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationListProvider);

    return AppScaffold(
      title: 'Notifications',
      body: ListView.separated(
        itemBuilder: (context, index) {
          final item = notifications[index];
          return CustomCard(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                  child: Icon(item.icon, color: Colors.teal),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: AppTextStyles.bodyLarge),
                      const SizedBox(height: AppSizes.xs),
                      Text(item.body, style: AppTextStyles.bodyRegular),
                    ],
                  ),
                ),
                Text(item.timestamp, style: AppTextStyles.caption),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSizes.md),
        itemCount: notifications.length,
      ),
    );
  }
}
