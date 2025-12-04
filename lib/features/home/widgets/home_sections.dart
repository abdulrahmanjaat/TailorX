import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../customers/services/customers_service.dart';
import '../../notifications/providers/notifications_providers.dart';
import '../../orders/models/order_model.dart';
import '../../orders/services/orders_service.dart';
import '../../profile/services/profile_service.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileStreamProvider);

    return profileAsync.when(
      data: (profile) {
        final userName = profile?.name ?? 'TailorX';
        return Row(
          children: [
            GestureDetector(
              onTap: () => context.push(AppRoutes.profile),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.surface.withValues(alpha: 0.9),
                backgroundImage: profile?.profileImagePath != null
                    ? FileImage(File(profile!.profileImagePath!))
                    : null,
                child: profile?.profileImagePath == null
                    ? const Icon(
                        Icons.person,
                        color: AppColors.primary,
                        size: AppSizes.iconMd,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userName, style: AppTextStyles.titleLarge),
                  Text('Studio workspace', style: AppTextStyles.caption),
                ],
              ),
            ),
            Consumer(
              builder: (context, ref, child) {
                final unreadCountAsync = ref.watch(unreadCountProvider);
                final unreadCount = unreadCountAsync.when(
                  data: (count) => count,
                  loading: () => 0,
                  error: (_, _) => 0,
                );

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: () => context.push(AppRoutes.notifications),
                      icon: const Icon(Icons.notifications_none),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.error,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : '$unreadCount',
                            style: const TextStyle(
                              color: AppColors.background,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
      loading: () => Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.surface.withValues(alpha: 0.9),
            child: const Icon(
              Icons.person,
              color: AppColors.primary,
              size: AppSizes.iconMd,
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Loading...', style: AppTextStyles.titleLarge),
                Text('Studio workspace', style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
      error: (_, _) => Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.surface.withValues(alpha: 0.9),
            child: const Icon(
              Icons.person,
              color: AppColors.primary,
              size: AppSizes.iconMd,
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TailorX', style: AppTextStyles.titleLarge),
                Text('Studio workspace', style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WelcomeCard extends ConsumerWidget {
  const WelcomeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersStreamProvider);
    final profileAsync = ref.watch(profileStreamProvider);

    return profileAsync.when(
      data: (profile) {
        final shopName = profile?.shopName ?? 'TailorX';
        return ordersAsync.when(
          data: (orders) {
            final today = DateTime.now();
            final todayStart = DateTime(today.year, today.month, today.day);
            final todayEnd = todayStart.add(const Duration(days: 1));

            // Count orders created today
            final todayOrders = orders.where((order) {
              return order.createdAt.isAfter(todayStart) &&
                  order.createdAt.isBefore(todayEnd);
            }).length;

            // Get upcoming orders (not completed)
            final upcomingOrders = orders
                .where((order) => order.status != OrderStatus.completed)
                .toList();

            // Get next delivery date
            String deliveryInfo = 'No upcoming deliveries';
            IconData deliveryIcon = Icons.calendar_today;

            if (upcomingOrders.isNotEmpty) {
              // Sort by delivery date and get the nearest one
              upcomingOrders.sort(
                (a, b) => a.deliveryDate.compareTo(b.deliveryDate),
              );
              final nextDelivery = upcomingOrders.first.deliveryDate;
              final now = DateTime.now();
              final daysUntilDelivery = nextDelivery.difference(now).inDays;

              if (daysUntilDelivery < 0) {
                deliveryInfo =
                    '${daysUntilDelivery.abs()} ${daysUntilDelivery.abs() == 1 ? 'day' : 'days'} overdue';
                deliveryIcon = Icons.warning;
              } else if (daysUntilDelivery == 0) {
                deliveryInfo = 'Delivery due today';
                deliveryIcon = Icons.today;
              } else if (daysUntilDelivery == 1) {
                deliveryInfo = 'Delivery tomorrow';
                deliveryIcon = Icons.event;
              } else if (daysUntilDelivery <= 7) {
                deliveryInfo = 'Delivery in $daysUntilDelivery days';
                deliveryIcon = Icons.schedule;
              } else {
                deliveryInfo = DateFormat('MMM d').format(nextDelivery);
                deliveryIcon = Icons.calendar_today;
              }
            }

            // Calculate total pending orders
            final pendingOrdersCount = upcomingOrders.length;

            return CustomCard(
              padding: const EdgeInsets.all(AppSizes.xl),
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 18),
                ),
              ],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, $shopName',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.background,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    'You have $todayOrders ${todayOrders == 1 ? 'order' : 'orders'} today',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.background.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
                    style: AppTextStyles.bodyRegular.copyWith(
                      color: AppColors.background.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSizes.sm),
                        decoration: BoxDecoration(
                          color: AppColors.background.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(deliveryIcon, color: AppColors.background),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              deliveryInfo,
                              style: AppTextStyles.bodyRegular.copyWith(
                                color: AppColors.background.withValues(
                                  alpha: 0.9,
                                ),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (pendingOrdersCount > 0) ...[
                              const SizedBox(height: 2),
                              Text(
                                '$pendingOrdersCount ${pendingOrdersCount == 1 ? 'order' : 'orders'} pending',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.background.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
          loading: () => CustomCard(
            padding: const EdgeInsets.all(AppSizes.xl),
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, ${profile?.shopName ?? 'TailorX'}',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.background,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                const Center(
                  child: CircularProgressIndicator(color: AppColors.background),
                ),
              ],
            ),
          ),
          error: (error, stack) {
            // For new users or errors, show welcome message with 0 orders
            // This is more user-friendly than showing an error
            return CustomCard(
              padding: const EdgeInsets.all(AppSizes.xl),
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 18),
                ),
              ],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${profile?.shopName ?? 'TailorX'}',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.background,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    'You have 0 orders today',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.background.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
                    style: AppTextStyles.bodyRegular.copyWith(
                      color: AppColors.background.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSizes.sm),
                        decoration: BoxDecoration(
                          color: AppColors.background.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.schedule,
                          color: AppColors.background,
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: Text(
                          'No upcoming fittings',
                          style: AppTextStyles.bodyRegular.copyWith(
                            color: AppColors.background.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => CustomCard(
        padding: const EdgeInsets.all(AppSizes.xl),
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.background),
        ),
      ),
      error: (_, _) => CustomCard(
        padding: const EdgeInsets.all(AppSizes.xl),
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, TailorX',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.background,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            const Center(
              child: CircularProgressIndicator(color: AppColors.background),
            ),
          ],
        ),
      ),
    );
  }
}

class ActionButtonsGrid extends StatelessWidget {
  const ActionButtonsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _ActionItem('Create Customer', Icons.person_add, AppRoutes.addCustomer),
      _ActionItem(
        'Add Measurement',
        Icons.straighten,
        AppRoutes.addMeasurement,
      ),
      _ActionItem('Create New Order', Icons.content_cut, AppRoutes.addOrder),
      _ActionItem(
        'All Orders',
        Icons.library_books_outlined,
        AppRoutes.ordersList,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;
        final crossAxisCount = constraints.maxWidth > 520 ? 4 : 2;
        final childAspectRatio = isCompact ? 0.85 : 1.05;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSizes.md,
            mainAxisSpacing: AppSizes.md,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return CustomCard(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.md,
              ),
              onTap: () => context.push(item.route),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      item.icon,
                      size: AppSizes.iconLg,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    item.label,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ActionItem {
  const _ActionItem(this.label, this.icon, this.route);
  final String label;
  final IconData icon;
  final String route;
}

class TodayStatsRow extends ConsumerWidget {
  const TodayStatsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersStreamProvider);
    final customersAsync = ref.watch(customersStreamProvider);

    return ordersAsync.when(
      data: (orders) {
        final today = DateTime.now();
        final todayStart = DateTime(today.year, today.month, today.day);
        final todayEnd = todayStart.add(const Duration(days: 1));

        // Count orders created today
        final todayOrders = orders.where((order) {
          return order.createdAt.isAfter(todayStart) &&
              order.createdAt.isBefore(todayEnd);
        }).length;

        // Count pending orders (newOrder and inProgress)
        final pendingOrders = orders.where((order) {
          return order.status == OrderStatus.newOrder ||
              order.status == OrderStatus.inProgress;
        }).length;

        // Count completed orders
        final completedOrders = orders.where((order) {
          return order.status == OrderStatus.completed;
        }).length;

        // Get customer count from stream
        final customerCount = customersAsync.maybeWhen(
          data: (customers) => customers.length,
          orElse: () => 0,
        );

        final stats = [
          ('Today Orders', todayOrders.toString(), Icons.assignment_turned_in),
          ('Pending', pendingOrders.toString(), Icons.timer),
          ('Completed', completedOrders.toString(), Icons.check_circle_outline),
          ('Customers', customerCount.toString(), Icons.people),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 360;
            final cards = stats
                .map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.sm),
                    child: CustomCard(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFFFFF), Color(0xFFEFF6F5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      child: _StatTile(label: s.$1, value: s.$2, icon: s.$3),
                    ),
                  ),
                )
                .toList();
            if (isNarrow) {
              return Column(children: cards);
            }
            return Row(
              children: List.generate(cards.length, (index) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index == cards.length - 1 ? 0 : AppSizes.sm,
                    ),
                    child: cards[index],
                  ),
                );
              }),
            );
          },
        );
      },
      loading: () => const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.sm),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, color: AppColors.primary, size: AppSizes.iconMd),
        ),
        const SizedBox(width: AppSizes.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption),
            Text(value, style: AppTextStyles.titleLarge),
          ],
        ),
      ],
    );
  }
}

class LatestOrdersList extends ConsumerWidget {
  const LatestOrdersList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Latest orders', style: AppTextStyles.titleLarge),
        const SizedBox(height: AppSizes.md),
        ordersAsync.when(
          data: (orders) {
            if (orders.isEmpty) {
              return CustomCard(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Center(
                  child: Text(
                    'No orders yet',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.dark.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              );
            }

            // Get latest 5 orders
            final latestOrders = orders.take(5).toList();

            return Column(
              children: latestOrders.map((order) {
                final deliveryDate = DateFormat(
                  'MMM d',
                ).format(order.deliveryDate);
                final orderTypes = order.items
                    .map((item) => item.orderType)
                    .join(', ');

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.sm),
                  child: CustomCard(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFFFFF), Color(0xFFEFF5F5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.dark.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 12),
                      ),
                    ],
                    onTap: () =>
                        context.push('${AppRoutes.orderDetail}/${order.id}'),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.15,
                        ),
                        child: Text(
                          order.customerName.isNotEmpty
                              ? order.customerName.substring(0, 1).toUpperCase()
                              : '?',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      title: Text(
                        order.customerName,
                        style: AppTextStyles.bodyLarge,
                      ),
                      subtitle: Wrap(
                        spacing: AppSizes.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Chip(
                            label: Text(
                              orderTypes.length > 20
                                  ? '${orderTypes.substring(0, 20)}...'
                                  : orderTypes,
                            ),
                            backgroundColor: AppColors.surface.withValues(
                              alpha: 0.9,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          Text(
                            'Delivery $deliveryDate',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.15),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.lg),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) {
            // For new users with no orders, show empty state instead of error
            // This handles cases where collection doesn't exist yet
            return CustomCard(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Center(
                child: Text(
                  'No orders yet',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.dark.withValues(alpha: 0.6),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
