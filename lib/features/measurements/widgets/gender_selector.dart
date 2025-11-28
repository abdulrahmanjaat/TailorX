import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/measurement_model.dart';

class GenderSelector extends StatelessWidget {
  const GenderSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final MeasurementGender? value;
  final ValueChanged<MeasurementGender> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: MeasurementGender.values
          .map(
            (gender) => Expanded(
              child: GestureDetector(
                onTap: () => onChanged(gender),
                child: Container(
                  margin: const EdgeInsets.only(right: AppSizes.sm),
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                  decoration: BoxDecoration(
                    color: gender == value
                        ? AppColors.primary
                        : AppColors.surface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppSizes.sm),
                  ),
                  child: Center(
                    child: Text(
                      gender.label,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: gender == value
                            ? AppColors.background
                            : AppColors.dark,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
