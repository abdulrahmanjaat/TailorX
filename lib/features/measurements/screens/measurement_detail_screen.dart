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
import '../controllers/measurements_controller.dart';
import '../models/measurement_model.dart';

class MeasurementDetailScreen extends ConsumerWidget {
  const MeasurementDetailScreen({super.key, required this.measurementId});

  final String measurementId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final measurement = _measurement(ref);

    if (measurement == null) {
      return AppScaffold(
        title: 'Measurement Details',
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return AppScaffold(
      title: 'Measurement Details',
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
                  Text(
                    measurement.customerName,
                    style: AppTextStyles.headlineMedium,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    '${measurement.gender.label} • Added ${_formatDate(measurement.createdAt)}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            _buildSection('Upper Body', measurement, [
              'chest',
              'shoulder',
              'sleeve',
              'neck',
              'arm',
              'bicep',
              'wrist',
              'shirtLength',
            ]),
            const SizedBox(height: AppSizes.lg),
            _buildSection('Lower Body', measurement, [
              'waist',
              'hip',
              'thigh',
              'knee',
              'calf',
              'ankle',
              'pantLength',
              'forkLength',
              'bottom',
            ]),
            const SizedBox(height: AppSizes.lg),
            _buildSection('Additional', measurement, [
              'backWidth',
              'frontLength',
              'belly',
              'height',
              'weight',
            ]),
            const SizedBox(height: AppSizes.lg),
            if (measurement.notes != null)
              CustomCard(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notes', style: AppTextStyles.titleLarge),
                    const SizedBox(height: AppSizes.sm),
                    Text(measurement.notes!, style: AppTextStyles.bodyRegular),
                  ],
                ),
              ),
            const SizedBox(height: AppSizes.xl),
            Center(
              child: AppButton(
                label: 'Edit',
                onPressed: () => context.push(
                  '${AppRoutes.addMeasurement}?measurementId=$measurementId',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  CustomCard _buildSection(
    String title,
    MeasurementModel measurement,
    List<String> keys,
  ) {
    return CustomCard(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSizes.sm),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: keys
                .map(
                  (key) => _ValueChip(
                    label: _label(key),
                    value: measurement.valueFor(key),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  MeasurementModel? _measurement(WidgetRef ref) {
    final measurementsAsync = ref.watch(measurementsProvider);
    final measurements = measurementsAsync.value ?? [];
    if (measurements.isEmpty) return null;
    try {
      return measurements.firstWhere((m) => m.id == measurementId);
    } catch (_) {
      return null;
    }
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  String _label(String key) {
    switch (key) {
      case 'pantLength':
        return 'Pant Length';
      case 'forkLength':
        return 'Fork Length';
      case 'backWidth':
        return 'Back Width';
      case 'frontLength':
        return 'Front Length';
      case 'shirtLength':
        return 'Shirt Length';
      default:
        return key[0].toUpperCase() + key.substring(1);
    }
  }
}

class _ValueChip extends StatelessWidget {
  const _ValueChip({required this.label, required this.value});

  final String label;
  final double? value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.sm),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value == null ? '--' : value!.toStringAsFixed(1),
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
