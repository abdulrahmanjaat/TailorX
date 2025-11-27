import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class TailorBottomNav extends StatefulWidget {
  const TailorBottomNav({super.key});

  @override
  State<TailorBottomNav> createState() => _TailorBottomNavState();
}

class _TailorBottomNavState extends State<TailorBottomNav> {
  int _currentIndex = 0;

  final _items = const [
    _NavItem('Home', Icons.home_filled),
    _NavItem('Orders', Icons.receipt_long),
    _NavItem('Customers', Icons.people_alt),
    _NavItem('Settings', Icons.settings_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            bottom: 0,
            left: AppSizes.lg,
            right: AppSizes.lg,
            child: ClipPath(
              clipper: _NavShellClipper(),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.lg,
                    vertical: AppSizes.md,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.dark, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.dark.withValues(alpha: 0.35),
                        blurRadius: 28,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Row(
                    children: List.generate(
                      _items.length,
                      (index) => _NavButton(
                        item: _items[index],
                        isActive: _currentIndex == index,
                        onTap: () => setState(() => _currentIndex = index),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: -18,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.secondary, AppColors.primary],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.45),
                      blurRadius: 22,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  color: AppColors.background,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isActive
                ? AppColors.surface.withValues(alpha: 0.35)
                : Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.icon,
                color: isActive
                    ? AppColors.background
                    : AppColors.background.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: AppTextStyles.caption.copyWith(
                  color: isActive
                      ? AppColors.background
                      : AppColors.background.withValues(alpha: 0.6),
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
                child: Text(item.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavShellClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double corner = 36;
    const double dipWidth = 110;
    const double dipDepth = 28;

    final path = Path();
    path.moveTo(0, corner);
    path.quadraticBezierTo(0, 0, corner, 0);

    final dipStart = (size.width - dipWidth) / 2;
    final dipEnd = dipStart + dipWidth;

    path.lineTo(dipStart - 12, 0);
    path.cubicTo(
      dipStart + 10,
      0,
      size.width / 2 - 40,
      dipDepth,
      size.width / 2,
      dipDepth + 10,
    );
    path.cubicTo(size.width / 2 + 40, dipDepth, dipEnd - 10, 0, dipEnd + 12, 0);

    path.lineTo(size.width - corner, 0);
    path.quadraticBezierTo(size.width, 0, size.width, corner);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _NavItem {
  const _NavItem(this.label, this.icon);
  final String label;
  final IconData icon;
}
