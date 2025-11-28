import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_inputs.dart';
import '../../../core/theme/app_text_styles.dart';

class MeasurementField extends StatelessWidget {
  const MeasurementField({
    super.key,
    required this.label,
    required this.controller,
  });

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyRegular),
        const SizedBox(height: AppSizes.xs),
        AppInputField(
          controller: controller,
          hintText: '0.0',
          keyboardType: TextInputType.number,
          prefix: const Icon(Icons.straighten),
        ),
      ],
    );
  }
}
