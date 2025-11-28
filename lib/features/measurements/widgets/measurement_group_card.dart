import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/custom_card.dart';

class MeasurementGroupCard extends StatelessWidget {
  const MeasurementGroupCard({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSizes.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 520;
              final itemsPerRow = isWide ? 3 : 2;
              final spacing = AppSizes.md;
              final tileWidth =
                  (constraints.maxWidth - (itemsPerRow - 1) * spacing) /
                  itemsPerRow;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: children
                    .map((child) => SizedBox(width: tileWidth, child: child))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
