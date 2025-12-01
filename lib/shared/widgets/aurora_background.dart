import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AuroraBackground extends StatelessWidget {
  const AuroraBackground({super.key, required this.child, this.colors});

  final Widget child;
  final List<Color>? colors;

  @override
  Widget build(BuildContext context) {
    final palette =
        colors ??
        [
          AppColors.background,
          AppColors.surface.withValues(alpha: 0.85),
          AppColors.primary.withValues(alpha: 0.3),
        ];

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: palette,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(children: [..._buildBlobBlobs(), child]),
    );
  }

  List<Widget> _buildBlobBlobs() {
    final blobColors = [
      AppColors.primary.withValues(alpha: 0.08),
      AppColors.secondary.withValues(alpha: 0.08),
      AppColors.primary.withValues(alpha: 0.05),
    ];

    final alignments = [
      const Alignment(-0.9, -0.8),
      const Alignment(0.8, -0.4),
      const Alignment(0.2, 0.9),
    ];

    final sizes = [220.0, 260.0, 200.0];

    return List.generate(blobColors.length, (index) {
      return Align(
        alignment: alignments[index],
        child: _BlurCircle(size: sizes[index], color: blobColors[index]),
      );
    });
  }
}

class _BlurCircle extends StatelessWidget {
  const _BlurCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [color, color.withValues(alpha: 0)],
            ),
          ),
        ),
      ),
    );
  }
}
