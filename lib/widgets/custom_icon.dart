import 'package:flutter/material.dart';

class CustomIcon extends StatelessWidget {
  final String iconPath;
  final double size;
  final Color? color;

  const CustomIcon({
    super.key,
    required this.iconPath,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      iconPath,
      width: size,
      height: size,
      color: color, // Optional: tint icon (e.g., for gold accents)
    );
  }
}