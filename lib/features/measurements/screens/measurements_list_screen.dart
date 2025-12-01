import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_inputs.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/services/snackbar_service.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../controllers/measurements_controller.dart';
import '../models/measurement_model.dart';
import '../widgets/measurement_tile.dart';

class MeasurementsListScreen extends ConsumerStatefulWidget {
  const MeasurementsListScreen({super.key});

  @override
  ConsumerState<MeasurementsListScreen> createState() =>
      _MeasurementsListScreenState();
}

class _MeasurementsListScreenState
    extends ConsumerState<MeasurementsListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final measurementsAsync = ref.watch(measurementsProvider);

    return measurementsAsync.when(
      data: (measurements) {
        final filtered = _filtered(measurements);
        return _buildContent(context, filtered);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Error: $error', style: AppTextStyles.bodyLarge)),
    );
  }

  Widget _buildContent(BuildContext context, List<MeasurementModel> filtered) {
    return AppScaffold(
      title: 'Measurements',
      padding: const EdgeInsets.all(AppSizes.lg),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addMeasurement),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: AppColors.background),
        label: Text(
          'Add Measurement',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.background),
        ),
      ),
      body: Column(
        children: [
          AppInputField(
            controller: _searchController,
            hintText: 'Search by customer name',
            prefix: const Icon(Icons.search, color: AppColors.primary),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSizes.lg),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No measurements found',
                      style: AppTextStyles.bodyLarge,
                    ),
                  )
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSizes.md),
                    itemBuilder: (context, index) {
                      final measurement = filtered[index];
                      return MeasurementTile(
                        measurement: measurement,
                        onTap: () => context.push(
                          '${AppRoutes.measurementsDetail}/${measurement.id}',
                        ),
                        onEdit: () => context.push(AppRoutes.addMeasurement),
                        onDelete: () => _confirmDelete(measurement.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<MeasurementModel> _filtered(List<MeasurementModel> items) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return items;
    return items
        .where((item) => item.customerName.toLowerCase().contains(query))
        .toList();
  }

  void _confirmDelete(String id) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Measurement'),
        content: const Text(
          'Are you sure you want to delete this measurement?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(measurementsProvider.notifier)
                  .deleteMeasurement(id);
              if (context.mounted) {
                SnackbarService.showSuccess(
                  context,
                  message: 'Measurement deleted',
                );
              }
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
