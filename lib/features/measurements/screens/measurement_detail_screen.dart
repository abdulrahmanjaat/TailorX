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
      padding: EdgeInsets.zero,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate card width: screen width - equal padding on both sides
          final horizontalPadding = AppSizes.lg;
          final cardWidth = constraints.maxWidth - (horizontalPadding * 2);

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: AppSizes.lg),
                  SizedBox(
                    width: cardWidth,
                    child: CustomCard(
                      padding: const EdgeInsets.all(AppSizes.xl),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.15,
                            ),
                            child: Text(
                              measurement.customerName
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: AppTextStyles.headlineMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSizes.md),
                          Text(
                            measurement.customerName,
                            style: AppTextStyles.headlineMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSizes.lg),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                measurement.gender == MeasurementGender.male
                                    ? Icons.male
                                    : measurement.gender ==
                                          MeasurementGender.female
                                    ? Icons.female
                                    : Icons.person,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: AppSizes.xs),
                              Text(
                                measurement.gender.label,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.sm),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: AppColors.dark.withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: AppSizes.xs),
                              Text(
                                'Added ${_formatDate(measurement.createdAt)}',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  _buildSection('Upper Body', measurement, cardWidth, [
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
                  _buildSection('Lower Body', measurement, cardWidth, [
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
                  _buildSection('Additional', measurement, cardWidth, [
                    'backWidth',
                    'frontLength',
                    'belly',
                    'height',
                    'weight',
                  ]),
                  const SizedBox(height: AppSizes.lg),
                  if (measurement.notes != null)
                    SizedBox(
                      width: cardWidth,
                      child: CustomCard(
                        padding: const EdgeInsets.all(AppSizes.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Notes', style: AppTextStyles.titleLarge),
                            const SizedBox(height: AppSizes.sm),
                            Text(
                              measurement.notes!,
                              style: AppTextStyles.bodyRegular,
                            ),
                          ],
                        ),
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
        },
      ),
    );
  }

  Widget _buildSection(
    String title,
    MeasurementModel measurement,
    double cardWidth,
    List<String> keys,
  ) {
    return SizedBox(
      width: cardWidth,
      child: CustomCard(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSizes.sm),
            Wrap(
              spacing: AppSizes.sm,
              runSpacing: AppSizes.sm,
              alignment: WrapAlignment.center,
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
    return SizedBox(
      width: 100,
      height: 70,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.sm),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value == null ? '--' : value!.toStringAsFixed(1),
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.xs),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
