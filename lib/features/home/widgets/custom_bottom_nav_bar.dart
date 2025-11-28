import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
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
    _NavItem('Clients', Icons.groups_rounded),
    _NavItem('Profile', Icons.person),
  ];

  void _handleTap(BuildContext context, int index) {
    final targetRoute = switch (index) {
      0 => AppRoutes.home,
      1 => AppRoutes.ordersList,
      2 => AppRoutes.customersList,
      3 => AppRoutes.profile,
      _ => AppRoutes.home,
    };

    final currentLocation = GoRouterState.of(context).uri.toString();
    if (currentLocation == targetRoute) return;

    setState(() => _currentIndex = index);
    context.push(targetRoute);
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final resolvedIndex = _indexFromLocation(location);
    if (resolvedIndex != _currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _currentIndex = resolvedIndex);
        }
      });
    }

    return SizedBox(
      height: 120,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _FloatingNavClipper(),
              child: Container(
                height: 74,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0E3A39), Color(0xFF1D5E5D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(44),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.dark.withValues(alpha: 0.22),
                      blurRadius: 24,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ...List.generate(
                      2,
                      (index) => _NavButton(
                        item: _items[index],
                        isActive: _currentIndex == index,
                        onTap: () => _handleTap(context, index),
                      ),
                    ),
                    const SizedBox(width: 56),
                    ...List.generate(
                      2,
                      (index) => _NavButton(
                        item: _items[index + 2],
                        isActive: _currentIndex == index + 2,
                        onTap: () => _handleTap(context, index + 2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 25,
            child: GestureDetector(
              onTap: () => context.push(AppRoutes.addCustomer),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.secondary, AppColors.primary],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 22,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  color: AppColors.background,
                  size: AppSizes.iconLg,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _indexFromLocation(String location) {
    if (location.startsWith(AppRoutes.ordersList) ||
        location.startsWith(AppRoutes.orderDetail)) {
      return 1;
    }
    if (location.startsWith(AppRoutes.customersList) ||
        location.startsWith(AppRoutes.customerDetail)) {
      return 2;
    }
    if (location.startsWith(AppRoutes.profile)) {
      return 3;
    }
    return 0;
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
    final color = isActive
        ? AppColors.background
        : AppColors.background.withValues(alpha: 0.5);
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, color: color, size: AppSizes.iconMd),
              const SizedBox(height: 6),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11,
                  color: color,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingNavClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const notchRadius = 36.0;
    final notchWidth = notchRadius * 2.4;
    final centerX = size.width / 2;
    final notchStart = centerX - notchWidth / 2;
    final notchEnd = centerX + notchWidth / 2;

    final path = Path()..moveTo(24, 0);
    path.quadraticBezierTo(0, 0, 0, 24);
    path.lineTo(0, size.height - 18);
    path.quadraticBezierTo(0, size.height, 24, size.height);
    path.lineTo(size.width - 24, size.height);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width,
      size.height - 18,
    );
    path.lineTo(size.width, 24);
    path.quadraticBezierTo(size.width, 0, size.width - 24, 0);
    path.lineTo(notchEnd, 0);
    path.quadraticBezierTo(notchEnd - 6, 0, notchEnd - 12, 6);
    path.cubicTo(
      centerX + notchRadius * 0.7,
      notchRadius + 14,
      centerX - notchRadius * 0.7,
      notchRadius + 14,
      notchStart + 12,
      6,
    );
    path.quadraticBezierTo(notchStart + 6, 0, notchStart, 0);
    path.lineTo(24, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _NavItem {
  const _NavItem(this.label, this.icon);
  final String label;
  final IconData icon;
}
