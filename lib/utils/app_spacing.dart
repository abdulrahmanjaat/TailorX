import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSpacing {
  static double get xs => 8.w;
  static double get sm => 12.w;
  static double get md => 16.w;
  static double get lg => 24.w;
  static double get xl => 32.w;
  static double get xxl => 40.w;

  static EdgeInsets pagePadding({bool dense = false}) {
    return EdgeInsets.symmetric(
      horizontal: dense ? 16.w : 20.w,
      vertical: dense ? 16.h : 24.h,
    );
  }

  static double responsiveMaxWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1200) return 900;
    if (width >= 900) return 720;
    return 560;
  }
}

