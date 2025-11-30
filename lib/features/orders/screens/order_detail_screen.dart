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
    final order = orders.where((item) => item.id == orderId).firstOrNull;

    if (order == null) {
      // Order was deleted, navigate back
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.pop();
        }
      });
      return AppScaffold(
        title: 'Order Details',
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
            CustomCard(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order Items', style: AppTextStyles.titleLarge),
                  const SizedBox(height: AppSizes.md),
                  ...order.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.md),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.orderType,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Qty: ${item.quantity} × \$${item.unitPrice.toStringAsFixed(2)}',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${item.lineTotal.toStringAsFixed(2)}',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: AppSizes.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal', style: AppTextStyles.bodyLarge),
                      Text(
                        '\$${order.subtotal.toStringAsFixed(2)}',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order Status', style: AppTextStyles.titleLarge),
                  const SizedBox(height: AppSizes.md),
                  _StatusOption(
                    label: 'New',
                    status: OrderStatus.newOrder,
                    currentStatus: order.status,
                    onTap: () {
                      ref
                          .read(ordersProvider.notifier)
                          .updateStatus(order.id, OrderStatus.newOrder);
                      SnackbarService.showSuccess(
                        context,
                        message: 'Status updated to New',
                      );
                    },
                  ),
                  const SizedBox(height: AppSizes.sm),
                  _StatusOption(
                    label: 'In Progress',
                    status: OrderStatus.inProgress,
                    currentStatus: order.status,
                    onTap: () {
                      ref
                          .read(ordersProvider.notifier)
                          .updateStatus(order.id, OrderStatus.inProgress);
                      SnackbarService.showSuccess(
                        context,
                        message: 'Status updated to In Progress',
                      );
                    },
                  ),
                  const SizedBox(height: AppSizes.sm),
                  _StatusOption(
                    label: 'Completed',
                    status: OrderStatus.completed,
                    currentStatus: order.status,
                    onTap: () {
                      ref
                          .read(ordersProvider.notifier)
                          .updateStatus(order.id, OrderStatus.completed);
                      SnackbarService.showSuccess(
                        context,
                        message: 'Status updated to Completed',
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            if (order.items.any((item) => item.measurementId != null))
              ...order.items
                  .where((item) => item.measurementId != null)
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.sm),
                      child: AppButton(
                        label: 'View ${item.orderType} Measurements',
                        onPressed: () => context.push(
                          '${AppRoutes.measurementsDetail}/${item.measurementId}',
                        ),
                        type: AppButtonType.secondary,
                      ),
                    ),
                  ),
            const SizedBox(height: AppSizes.md),
            AppButton(
              label: 'Edit Order',
              onPressed: () =>
                  context.push('${AppRoutes.editOrder}/${orderId}'),
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

              // Delete the order first
              ref.read(ordersProvider.notifier).deleteOrder(id);

              // Show success message
              SnackbarService.showSuccess(
                context,
                message: 'Order deleted successfully',
              );

              // Navigate back after a small delay to ensure state updates
              Future.delayed(const Duration(milliseconds: 50), () {
                if (context.mounted) {
                  context.pop();
                }
              });
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

class _StatusOption extends StatelessWidget {
  const _StatusOption({
    required this.label,
    required this.status,
    required this.currentStatus,
    required this.onTap,
  });

  final String label;
  final OrderStatus status;
  final OrderStatus currentStatus;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = status == currentStatus;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: isSelected
              ? status.color.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.sm),
          border: Border.all(
            color: isSelected ? status.color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? status.color : Colors.transparent,
                border: Border.all(color: status.color, width: 2),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? status.color : AppColors.dark,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: status.color, size: 20),
          ],
        ),
      ),
    );
  }
}
