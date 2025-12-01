import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/services/secure_storage_service.dart';
import '../routes/app_routes.dart';

/// Middleware to handle navigation based on auth and onboarding state
class AuthMiddleware {
  /// Determine the initial route based on user state
  static Future<String> getInitialRoute(WidgetRef ref) async {
    final secureStorage = SecureStorageService.instance;

    // Check if user has seen onboarding
    final hasSeenOnboarding = await secureStorage.hasSeenOnboarding();

    // If user hasn't seen onboarding, show it
    if (!hasSeenOnboarding) {
      return AppRoutes.onboarding;
    }

    // Check if user is logged in
    final isLoggedIn = await secureStorage.isLoggedIn();

    // If logged in, go to home
    if (isLoggedIn) {
      return AppRoutes.home;
    }

    // Otherwise, show login
    return AppRoutes.login;
  }

  /// Redirect logic for routes
  static Future<String?> redirect(
    BuildContext context,
    GoRouterState state,
    WidgetRef ref,
  ) async {
    final secureStorage = SecureStorageService.instance;
    final currentLocation = state.uri.toString();

    // Allow splash screen
    if (currentLocation == AppRoutes.splash) {
      return null;
    }

    // Check onboarding status
    final hasSeenOnboarding = await secureStorage.hasSeenOnboarding();

    // If user hasn't seen onboarding and is not on onboarding screen
    if (!hasSeenOnboarding && currentLocation != AppRoutes.onboarding) {
      return AppRoutes.onboarding;
    }

    // If user has seen onboarding, check login status
    if (hasSeenOnboarding) {
      final isLoggedIn = await secureStorage.isLoggedIn();

      // Protected routes (require login)
      final protectedRoutes = [
        AppRoutes.home,
        AppRoutes.profile,
        AppRoutes.settings,
        AppRoutes.ordersList,
        AppRoutes.addOrder,
        AppRoutes.customersList,
        AppRoutes.addCustomer,
        AppRoutes.measurementsList,
        AppRoutes.addMeasurement,
      ];

      final isProtectedRoute = protectedRoutes.any(
        (route) => currentLocation.startsWith(route),
      );

      // If trying to access protected route without login
      if (isProtectedRoute && !isLoggedIn) {
        return AppRoutes.login;
      }

      // If logged in and trying to access auth screens, redirect to home
      if (isLoggedIn &&
          (currentLocation == AppRoutes.login ||
              currentLocation == AppRoutes.signup ||
              currentLocation == AppRoutes.onboarding)) {
        return AppRoutes.home;
      }
    }

    return null; // No redirect needed
  }
}
