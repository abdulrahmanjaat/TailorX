import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_inputs.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../models/customer_model.dart';
import '../services/customers_service.dart';
import '../widgets/customer_card.dart';

class CustomersListScreen extends ConsumerStatefulWidget {
  const CustomersListScreen({super.key});

  @override
  ConsumerState<CustomersListScreen> createState() =>
      _CustomersListScreenState();
}

class _CustomersListScreenState extends ConsumerState<CustomersListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersStreamProvider);

    return customersAsync.when(
      data: (customers) {
        final filtered = _filtered(customers);
        return _buildContent(context, filtered);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          'No customers yet',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.dark.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<CustomerModel> filtered) {
    return AppScaffold(
      title: 'Customers',
      padding: const EdgeInsets.all(AppSizes.lg),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addCustomer),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: AppColors.background),
        label: Text(
          'Add Customer',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.background),
        ),
      ),
      body: Column(
        children: [
          AppInputField(
            controller: _searchController,
            hintText: 'Search by name or phone',
            prefix: const Icon(Icons.search, color: AppColors.primary),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSizes.lg),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No customers found',
                      style: AppTextStyles.bodyLarge,
                    ),
                  )
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSizes.md),
                    itemBuilder: (context, index) {
                      final customer = filtered[index];
                      return CustomerCard(
                        customer: customer,
                        onTap: () => context.push(
                          '${AppRoutes.customerDetail}/${customer.id}',
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<CustomerModel> _filtered(List<CustomerModel> customers) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return customers;
    return customers
        .where(
          (customer) =>
              customer.name.toLowerCase().contains(query) ||
              customer.phone.toLowerCase().contains(query),
        )
        .toList();
  }
}
