import 'package:flutter/widgets.dart';

class Responsive {
  Responsive._();

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1024;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static double columnWidth(
    BuildContext context, {
    double mobile = 1,
    double tablet = 0.6,
    double desktop = 0.4,
  }) {
    final size = MediaQuery.of(context).size.width;
    if (size >= 1024) return desktop;
    if (size >= 600) return tablet;
    return mobile;
  }
}
