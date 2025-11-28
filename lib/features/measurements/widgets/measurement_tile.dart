import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/custom_card.dart';
import '../models/measurement_model.dart';

class MeasurementTile extends StatelessWidget {
  const MeasurementTile({
    super.key,
    required this.measurement,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final MeasurementModel measurement;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              child: Text(
                measurement.gender.label.substring(0, 1),
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            title: Text(
              measurement.customerName,
              style: AppTextStyles.titleLarge,
            ),
            subtitle: Text(
              '${measurement.gender.label} • Updated ${_formatDate(measurement.createdAt)}',
              style: AppTextStyles.caption,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.primary,
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(top: AppSizes.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ValueChip(label: 'Chest', value: measurement.values['chest']),
                _ValueChip(label: 'Waist', value: measurement.values['waist']),
                _ValueChip(
                  label: 'Sleeve',
                  value: measurement.values['sleeve'],
                ),
                _ValueChip(
                  label: 'Length',
                  value: measurement.values['pantLength'],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}

class _ValueChip extends StatelessWidget {
  const _ValueChip({required this.label, required this.value});

  final String label;
  final double? value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value == null ? '--' : value!.toStringAsFixed(1),
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
