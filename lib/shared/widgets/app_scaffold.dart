import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.padding = EdgeInsets.zero,
    this.bottomNavigationBar,
    this.showBackButton = true,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final EdgeInsetsGeometry padding;
  final Widget? bottomNavigationBar;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    // Determine if back button should be shown
    bool canPop = false;
    bool isRootRoute = false;
    String? currentRoute;

    try {
      final router = GoRouter.of(context);
      final currentLocation = GoRouterState.of(context).uri.toString();
      final locationWithoutQuery = currentLocation.split('?').first;

      // Root routes that shouldn't show back button when navigated via bottom nav
      // These must be EXACT matches (not just "starts with")
      final rootRoutes = ['/home', '/orders', '/customers', '/profile'];

      // Check if current location is EXACTLY a root route
      // Detail routes like /orders/detail/123 should NOT match /orders
      isRootRoute = rootRoutes.any((route) {
        // Exact match (with or without trailing slash)
        final isMatch =
            locationWithoutQuery == route || locationWithoutQuery == '$route/';
        if (isMatch) currentRoute = route;
        return isMatch;
      });

      // If we're on a root route, don't show back button on Home; on other roots, show back to Home
      if (isRootRoute) {
        if (currentRoute == '/home') {
          canPop = false;
        } else {
          // Force show back button for root tabs other than home
          canPop = showBackButton;
        }
      } else {
        // For non-root routes (detail screens, edit screens, etc.)
        // ALWAYS show back button if showBackButton is true
        // This ensures back button appears even when GoRouter.canPop() returns false
        // (which can happen when navigating via bottom nav using context.go())
        if (showBackButton) {
          // First try to check if we can actually pop
          canPop = router.canPop();

          // If GoRouter says we can't pop, check Navigator as fallback
          if (!canPop) {
            canPop = Navigator.of(context).canPop();
          }

          // If both say we can't pop, still show back button for non-root routes
          // This handles the case where bottom nav uses context.go() which clears the stack
          // but we still want back button on detail screens
          if (!canPop) {
            // Always show back button for non-root routes when showBackButton is true
            // This ensures detail screens always have back button
            canPop = true;
          }
        }
      }
    } catch (_) {
      // If GoRouter context is not available, try Navigator
      try {
        canPop = Navigator.of(context).canPop();
      } catch (_) {
        // If Navigator also fails, default to false
        canPop = false;
      }
    }

    final shouldShowBack = showBackButton && canPop;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: title == null
          ? null
          : AppBar(
              // Disable automatic leading since we're providing custom leading widget
              // This ensures our custom back button icon is always used when needed
              automaticallyImplyLeading: false,
              // Show custom back button only when we can pop and showBackButton is true
              leading: shouldShowBack
                  ? IconButton(
                      onPressed: () {
                        final router = GoRouter.of(context);
                        final navigator = Navigator.of(context);
                        if (router.canPop()) {
                          router.pop();
                          return;
                        }
                        if (navigator.canPop()) {
                          navigator.maybePop();
                          return;
                        }
                        // If on a root tab other than Home, go to Home
                        if (currentRoute != null &&
                            currentRoute != '/home' &&
                            currentRoute!.startsWith('/')) {
                          context.go('/home');
                        }
                      },
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    )
                  : null,
              title: Text(title!, style: AppTextStyles.titleLarge),
              actions: actions,
              backgroundColor: Colors.transparent,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              flexibleSpace: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.05),
              AppColors.background,
              AppColors.secondary.withValues(alpha: 0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.primary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -150,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.secondary.withValues(alpha: 0.08),
                      AppColors.secondary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(padding: padding, child: body),
            ),
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
