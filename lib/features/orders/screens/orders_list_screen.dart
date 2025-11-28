import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_inputs.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../controllers/orders_controller.dart';
import '../models/order_model.dart';
import '../widgets/custom_filter_chip.dart';
import '../widgets/order_card.dart';

class OrdersListScreen extends ConsumerStatefulWidget {
  const OrdersListScreen({super.key});

  @override
  ConsumerState<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends ConsumerState<OrdersListScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(ordersProvider);
    final filtered = orders.where(_matchesFilters).toList();

    return AppScaffold(
      title: 'Orders',
      padding: const EdgeInsets.all(AppSizes.lg),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addOrder),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: AppColors.background),
        label: Text(
          'New Order',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.background),
        ),
      ),
      body: Column(
        children: [
          AppInputField(
            controller: _searchController,
            hintText: 'Search customer or order type',
            prefix: const Icon(Icons.search, color: AppColors.primary),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSizes.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildChip('All'),
                const SizedBox(width: AppSizes.sm),
                _buildChip('New'),
                const SizedBox(width: AppSizes.sm),
                _buildChip('In Progress'),
                const SizedBox(width: AppSizes.sm),
                _buildChip('Completed'),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No orders found',
                      style: AppTextStyles.bodyLarge,
                    ),
                  )
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSizes.md),
                    itemBuilder: (context, index) {
                      final order = filtered[index];
                      return OrderCard(
                        order: order,
                        onTap: () => context.push(
                          '${AppRoutes.orderDetail}/${order.id}',
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  bool _matchesFilters(OrderModel order) {
    final query = _searchController.text.trim().toLowerCase();
    final matchesSearch =
        query.isEmpty ||
        order.customerName.toLowerCase().contains(query) ||
        order.orderType.toLowerCase().contains(query);

    if (_selectedFilter == 'All') return matchesSearch;

    final statusMatches = switch (_selectedFilter) {
      'New' => order.status == OrderStatus.newOrder,
      'In Progress' => order.status == OrderStatus.inProgress,
      'Completed' => order.status == OrderStatus.completed,
      _ => true,
    };

    return matchesSearch && statusMatches;
  }

  Widget _buildChip(String label) {
    return CustomFilterChip(
      label: label,
      isSelected: _selectedFilter == label,
      onTap: () => setState(() => _selectedFilter = label),
    );
  }
}
