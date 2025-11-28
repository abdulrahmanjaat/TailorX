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
import '../../../shared/widgets/custom_card.dart';
import '../controllers/orders_controller.dart';
import '../models/order_model.dart';
import '../widgets/order_amount_section.dart';
import '../widgets/order_detail_tile.dart';
import '../widgets/order_status_badge.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final order = orders.firstWhere(
      (item) => item.id == orderId,
      orElse: () => throw Exception('Order not found'),
    );

    return AppScaffold(
      title: 'Order Details',
      padding: const EdgeInsets.all(AppSizes.lg),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomCard(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          order.customerName,
                          style: AppTextStyles.headlineMedium,
                        ),
                      ),
                      OrderStatusBadge(status: order.status),
                    ],
                  ),
                  const SizedBox(height: AppSizes.lg),
                  OrderDetailTile(
                    label: 'Order Type',
                    value: order.orderType,
                    icon: Icons.category_outlined,
                  ),
                  OrderDetailTile(
                    label: 'Created On',
                    value: _formatDate(order.createdAt),
                    icon: Icons.calendar_month_outlined,
                  ),
                  OrderDetailTile(
                    label: 'Delivery Date',
                    value: _formatDate(order.deliveryDate),
                    icon: Icons.event_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            OrderAmountSection(
              total: order.totalAmount,
              advance: order.advanceAmount,
              remaining: order.remainingAmount,
            ),
            const SizedBox(height: AppSizes.lg),
            if (order.notes != null && order.notes!.isNotEmpty)
              CustomCard(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notes', style: AppTextStyles.titleLarge),
                    const SizedBox(height: AppSizes.sm),
                    Text(order.notes!, style: AppTextStyles.bodyRegular),
                  ],
                ),
              ),
            const SizedBox(height: AppSizes.lg),
            CustomCard(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status', style: AppTextStyles.bodyRegular),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          order.status == OrderStatus.completed
                              ? 'Completed'
                              : order.status.label,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: order.status == OrderStatus.completed
                                ? AppColors.success
                                : AppColors.dark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: order.status == OrderStatus.completed,
                    onChanged: (value) {
                      final newStatus = value
                          ? OrderStatus.completed
                          : OrderStatus.inProgress;
                      ref
                          .read(ordersProvider.notifier)
                          .updateStatus(order.id, newStatus);
                    },
                    activeThumbColor: AppColors.success,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            if (order.measurementId != null)
              AppButton(
                label: 'View Measurements',
                onPressed: () => context.push(
                  '${AppRoutes.measurementsDetail}/${order.measurementId}',
                ),
                type: AppButtonType.secondary,
              ),
            const SizedBox(height: AppSizes.md),
            AppButton(
              label: 'Edit Order',
              onPressed: () => context.push(AppRoutes.addOrder),
              type: AppButtonType.secondary,
            ),
            const SizedBox(height: AppSizes.md),
            AppButton(
              label: 'Delete Order',
              onPressed: () => _confirmDelete(context, ref, order.id),
              type: AppButtonType.secondary,
            ),
            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Order'),
        content: const Text('Are you sure you want to delete this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(ordersProvider.notifier).deleteOrder(id);
              context.pop();
              SnackbarService.showSuccess(context, message: 'Order deleted');
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
