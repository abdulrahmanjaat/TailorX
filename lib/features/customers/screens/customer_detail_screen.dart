import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_buttons.dart';
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

    return AppScaffold(
      title: 'Customer Details',
      padding: const EdgeInsets.all(AppSizes.lg),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderCard(customer: customer),
            const SizedBox(height: AppSizes.lg),
            _SectionHeader(
              title: 'Measurements',
              trailing: measurements.isEmpty
                  ? AppButton(
                      label: 'Add',
                      onPressed: () => context.push(AppRoutes.addMeasurement),
                      type: AppButtonType.secondary,
                      isSmall: true,
                    )
                  : null,
            ),
            const SizedBox(height: AppSizes.sm),
            if (measurements.isEmpty)
              const _EmptyState(message: 'No measurements recorded yet.')
            else
              ...measurements.map(
                (measurement) => _MeasurementCard(measurement: measurement),
              ),
            const SizedBox(height: AppSizes.lg),
            _SectionHeader(title: 'Orders'),
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

class _MeasurementCard extends StatelessWidget {
  const _MeasurementCard({required this.measurement});

  final MeasurementModel measurement;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: CustomCard(
        onTap: () =>
            context.push('${AppRoutes.measurementsDetail}/${measurement.id}'),
        child: Row(
          children: [
            Icon(
              measurement.gender == MeasurementGender.female
                  ? Icons.female
                  : Icons.male,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${measurement.gender.label} measurements',
                    style: AppTextStyles.titleLarge,
                  ),
                  Text(
                    'Updated ${_formatDate(measurement.createdAt)}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: AppSizes.iconSm,
              color: AppColors.primary,
            ),
          ],
        ),
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
  const _SectionHeader({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTextStyles.titleLarge)),
        if (trailing != null) trailing!,
      ],
    );
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
