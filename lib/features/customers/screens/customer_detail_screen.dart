import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../measurements/controllers/measurements_controller.dart';
import '../../measurements/models/measurement_model.dart';
import '../../orders/controllers/orders_controller.dart';
import '../../orders/models/order_model.dart';
import '../../orders/widgets/order_status_badge.dart';
import '../controllers/customers_controller.dart';
import '../models/customer_model.dart';
import '../widgets/customer_detail_tile.dart';

class CustomerDetailScreen extends ConsumerWidget {
  const CustomerDetailScreen({super.key, required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customer = _customer(ref);
    final measurements = ref
        .watch(measurementsProvider)
        .where((m) => m.customerId == customer.id)
        .toList();
    final orders = ref
        .watch(ordersProvider)
        .where((o) => o.customerId == customer.id)
        .toList();

    // Group measurements by order type
    final groupedMeasurements = <String, List<MeasurementModel>>{};
    for (final measurement in measurements) {
      final key = measurement.orderType;
      groupedMeasurements.putIfAbsent(key, () => []).add(measurement);
    }

    // Group orders by measurement (orders linked to measurements)
    final ordersByMeasurement = <String, List<OrderModel>>{};
    for (final order in orders) {
      if (order.measurementId != null) {
        ordersByMeasurement
            .putIfAbsent(order.measurementId!, () => [])
            .add(order);
      }
    }

    return AppScaffold(
      title: 'Customer Details',
      padding: const EdgeInsets.all(AppSizes.lg),
      floatingActionButton: _buildFloatingActionButtons(context, customer),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderCard(customer: customer),
            const SizedBox(height: AppSizes.lg),
            _SectionHeader(title: 'Measurements by Type'),
            const SizedBox(height: AppSizes.sm),
            if (measurements.isEmpty)
              const _EmptyState(message: 'No measurements recorded yet.')
            else
              ...groupedMeasurements.entries.map(
                (entry) => _MeasurementGroupCard(
                  orderType: entry.key,
                  measurements: entry.value,
                  ordersByMeasurement: ordersByMeasurement,
                ),
              ),
            const SizedBox(height: AppSizes.lg),
            _SectionHeader(title: 'All Orders'),
            const SizedBox(height: AppSizes.sm),
            if (orders.isEmpty)
              const _EmptyState(message: 'No orders yet.')
            else
              ...orders.map((order) => _OrderCard(order: order)),
            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons(
    BuildContext context,
    CustomerModel customer,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'add_measurement',
          onPressed: () => context.push(
            '${AppRoutes.addMeasurement}?customerId=${customer.id}',
          ),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.straighten, color: AppColors.background),
        ),
        const SizedBox(height: AppSizes.md),
        FloatingActionButton(
          heroTag: 'add_order',
          onPressed: () =>
              context.push('${AppRoutes.addOrder}?customerId=${customer.id}'),
          backgroundColor: AppColors.secondary,
          child: const Icon(
            Icons.add_shopping_cart,
            color: AppColors.background,
          ),
        ),
      ],
    );
  }

  CustomerModel _customer(WidgetRef ref) {
    final customers = ref.watch(customersProvider);
    return customers.firstWhere(
      (customer) => customer.id == customerId,
      orElse: () => throw Exception('Customer not found'),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.customer});

  final CustomerModel customer;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Text(
              customer.name.substring(0, 1),
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Text(customer.name, style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppSizes.md),
          CustomerDetailTile(
            label: 'Phone',
            value: customer.phone,
            icon: Icons.phone_outlined,
          ),
          if (customer.email != null)
            CustomerDetailTile(
              label: 'Email',
              value: customer.email!,
              icon: Icons.email_outlined,
            ),
          if (customer.address != null)
            CustomerDetailTile(
              label: 'Address',
              value: customer.address!,
              icon: Icons.location_on_outlined,
            ),
          CustomerDetailTile(
            label: 'Customer Since',
            value: _formatDate(customer.createdAt),
            icon: Icons.history,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}

class _MeasurementGroupCard extends StatelessWidget {
  const _MeasurementGroupCard({
    required this.orderType,
    required this.measurements,
    required this.ordersByMeasurement,
  });

  final String orderType;
  final List<MeasurementModel> measurements;
  final Map<String, List<OrderModel>> ordersByMeasurement;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.lg),
      child: CustomCard(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.category, color: AppColors.primary),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    orderType,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${measurements.length} ${measurements.length == 1 ? 'set' : 'sets'}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            ...measurements.map(
              (measurement) => Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.md),
                child: _MeasurementCard(
                  measurement: measurement,
                  linkedOrders: ordersByMeasurement[measurement.id] ?? [],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeasurementCard extends StatelessWidget {
  const _MeasurementCard({
    required this.measurement,
    required this.linkedOrders,
  });

  final MeasurementModel measurement;
  final List<OrderModel> linkedOrders;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(AppSizes.md),
      onTap: () =>
          context.push('${AppRoutes.measurementsDetail}/${measurement.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                measurement.gender == MeasurementGender.female
                    ? Icons.female
                    : Icons.male,
                color: AppColors.primary,
                size: AppSizes.iconMd,
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${measurement.gender.label} - ${_formatDate(measurement.createdAt)}',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (measurement.notes != null &&
                        measurement.notes!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSizes.xs),
                        child: Text(
                          measurement.notes!,
                          style: AppTextStyles.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              if (linkedOrders.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm,
                    vertical: AppSizes.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.sm),
                  ),
                  child: Text(
                    '${linkedOrders.length} ${linkedOrders.length == 1 ? 'order' : 'orders'}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(width: AppSizes.xs),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: AppSizes.iconSm,
                color: AppColors.primary,
              ),
            ],
          ),
          if (linkedOrders.isNotEmpty) ...[
            const SizedBox(height: AppSizes.sm),
            const Divider(),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Linked Orders:',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.xs),
            ...linkedOrders.map(
              (order) => Padding(
                padding: const EdgeInsets.only(top: AppSizes.xs),
                child: InkWell(
                  onTap: () =>
                      context.push('${AppRoutes.orderDetail}/${order.id}'),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: AppSizes.iconSm,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSizes.xs),
                      Expanded(
                        child: Text(
                          '${order.orderType} - ${_formatDate(order.createdAt)}',
                          style: AppTextStyles.caption,
                        ),
                      ),
                      OrderStatusBadge(status: order.status),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: CustomCard(
        onTap: () => context.push('${AppRoutes.orderDetail}/${order.id}'),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.orderType, style: AppTextStyles.titleLarge),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    'Delivery ${_formatDate(order.deliveryDate)}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            OrderStatusBadge(status: order.status),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTextStyles.titleLarge);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.md),
      ),
      child: Text(message, style: AppTextStyles.bodyRegular),
    );
  }
}
