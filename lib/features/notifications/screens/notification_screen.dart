import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../controllers/notification_controller.dart';

enum _NotificationFilter { all, read, unread }

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  _NotificationFilter _filter = _NotificationFilter.all;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _NotificationFilter.values.length,
      vsync: this,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {
        _filter = _NotificationFilter.values[_tabController.index];
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationListProvider);
    final notifier = ref.read(notificationListProvider.notifier);
    final allRead =
        notifications.isNotEmpty && notifications.every((item) => item.isRead);

    final filtered = notifications.where((item) {
      switch (_filter) {
        case _NotificationFilter.all:
          return true;
        case _NotificationFilter.read:
          return item.isRead;
        case _NotificationFilter.unread:
          return !item.isRead;
      }
    }).toList();

    return AppScaffold(
      padding: EdgeInsets.zero,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.lg,
                vertical: AppSizes.md,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  Expanded(
                    child: Text(
                      'Notifications',
                      style: AppTextStyles.titleLarge,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(AppSizes.sm),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.notifications_active_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: TabBar(
                        controller: _tabController,
                        indicator: const _FixedUnderlineIndicator(
                          color: AppColors.primary,
                          thickness: 2,
                          width: 42,
                        ),
                        indicatorSize: TabBarIndicatorSize.label,
                        labelPadding: EdgeInsets.zero,
                        dividerColor: Colors.transparent,
                        overlayColor: WidgetStateProperty.all(
                          Colors.transparent,
                        ),
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.dark.withValues(
                          alpha: 0.6,
                        ),
                        labelStyle: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: AppTextStyles.bodyRegular
                            .copyWith(fontWeight: FontWeight.w500),
                        tabs: const [
                          Tab(text: 'All'),
                          Tab(text: 'Read'),
                          Tab(text: 'Unread'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.lg),
                  GestureDetector(
                    onTap: allRead ? null : notifier.markAllRead,
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: allRead
                                  ? AppColors.dark.withValues(alpha: 0.3)
                                  : AppColors.primary,
                              width: 1.5,
                            ),
                            color: allRead
                                ? AppColors.surface
                                : AppColors.primary.withValues(alpha: 0.12),
                          ),
                          child: allRead
                              ? const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: AppColors.primary,
                                )
                              : null,
                        ),
                        const SizedBox(width: AppSizes.xs),
                        Text(
                          'Mark all as read',
                          style: AppTextStyles.bodyRegular.copyWith(
                            color: AppColors.dark.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            Expanded(
              child: filtered.isEmpty
                  ? const _EmptyNotifications()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.lg,
                        vertical: AppSizes.sm,
                      ),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSizes.md),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return _NotificationCard(
                          item: item,
                          onTap: () {
                            notifier.markAsRead(item.id);
                            // Navigate to order detail if orderId exists
                            if (item.orderId != null) {
                              context.push(
                                '${AppRoutes.orderDetail}/${item.orderId}',
                              );
                            }
                          },
                          onDismissed: () => notifier.remove(item.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    required this.onTap,
    required this.onDismissed,
  });

  final NotificationItem item;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    final leftAccent = item.isRead
        ? AppColors.surface.withValues(alpha: 0.9)
        : AppColors.primary;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        margin: const EdgeInsets.only(left: AppSizes.xs),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 26),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border(left: BorderSide(color: leftAccent, width: 3)),
            boxShadow: [
              BoxShadow(
                color: AppColors.dark.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          item.timestamp,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.dark.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      item.body,
                      style: AppTextStyles.bodyRegular.copyWith(
                        color: AppColors.dark.withValues(alpha: 0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                Icons.mark_email_unread_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            Text(
              'No notifications',
              style: AppTextStyles.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'You’re all caught up for now. New alerts will appear here.',
              style: AppTextStyles.bodyRegular.copyWith(
                color: AppColors.dark.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FixedUnderlineIndicator extends Decoration {
  const _FixedUnderlineIndicator({
    required this.color,
    required this.width,
    this.thickness = 2,
  });

  final Color color;
  final double width;
  final double thickness;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _FixedUnderlinePainter(
      color: color,
      width: width,
      thickness: thickness,
    );
  }
}

class _FixedUnderlinePainter extends BoxPainter {
  _FixedUnderlinePainter({
    required this.color,
    required this.width,
    required this.thickness,
  });

  final Color color;
  final double width;
  final double thickness;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    if (configuration.size == null) return;
    final rect = offset & configuration.size!;
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    final indicatorWidth = width.clamp(0.0, rect.width);
    final startX = rect.center.dx - indicatorWidth / 2;
    final endX = rect.center.dx + indicatorWidth / 2;
    final y = rect.bottom - thickness / 2;

    canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
  }
}
