import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/login_options_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/customers/screens/add_customer_screen.dart';
import '../../features/customers/screens/customer_detail_screen.dart';
import '../../features/customers/screens/customers_list_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/measurements/screens/add_measurement_screen.dart';
import '../../features/measurements/screens/measurement_detail_screen.dart';
import '../../features/measurements/screens/measurements_list_screen.dart';
import '../../features/notifications/screens/notification_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/orders/screens/add_order_screen.dart';
import '../../features/orders/screens/edit_order_screen.dart';
import '../../features/orders/screens/order_detail_screen.dart';
import '../../features/orders/screens/order_receipt_screen.dart';
import '../../features/orders/screens/orders_list_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/terms_privacy_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import 'app_routes.dart';

/// Creates a smooth page transition for navigation
Page<T> _buildPageWithTransition<T extends Object?>(
  Widget child,
  GoRouterState state,
) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder:
        (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          // Use fade and slide transition for smooth navigation
          const begin = Offset(0.0, 0.02);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          var slideAnimation = Tween(
            begin: begin,
            end: end,
          ).animate(CurvedAnimation(parent: animation, curve: curve));

          var fadeAnimation = Tween(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(parent: animation, curve: curve));

          return FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(position: slideAnimation, child: child),
          );
        },
    transitionDuration: const Duration(milliseconds: 250),
  );
}

/// Custom page with transition
class CustomTransitionPage<T> extends Page<T> {
  final Widget child;
  final Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  )
  transitionsBuilder;
  final Duration transitionDuration;

  const CustomTransitionPage({
    required super.key,
    required this.child,
    required this.transitionsBuilder,
    this.transitionDuration = const Duration(milliseconds: 300),
  });

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      transitionDuration: transitionDuration,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: transitionsBuilder,
    );
  }
}

final appRouterProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splash,
        pageBuilder: (context, state) =>
            _buildPageWithTransition(const SplashScreen(), state),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRoutes.onboarding,
        pageBuilder: (context, state) =>
            _buildPageWithTransition(const OnboardingScreen(), state),
      ),
      GoRoute(
        path: AppRoutes.loginOptions,
        name: AppRoutes.loginOptions,
        pageBuilder: (context, state) =>
            _buildPageWithTransition(const LoginOptionsScreen(), state),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.login,
        pageBuilder: (context, state) =>
            _buildPageWithTransition(const LoginScreen(), state),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: AppRoutes.signup,
        pageBuilder: (context, state) =>
            _buildPageWithTransition(const SignupScreen(), state),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: AppRoutes.home,
        pageBuilder: (context, state) =>
            _buildPageWithTransition(const HomeScreen(), state),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: AppRoutes.profile,
        pageBuilder: (context, state) =>
            _buildPageWithTransition(const ProfileScreen(), state),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        name: AppRoutes.editProfile,
        pageBuilder: (context, state) =>
            _buildPageWithTransition(const EditProfileScreen(), state),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: AppRoutes.settings,
        pageBuilder: (context, state) =>
            _buildPageWithTransition(const SettingsScreen(), state),
      ),
      GoRoute(
        path: AppRoutes.termsPrivacy,
        name: AppRoutes.termsPrivacy,
        pageBuilder: (context, state) =>
            _buildPageWithTransition(const TermsPrivacyScreen(), state),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: AppRoutes.notifications,
        pageBuilder: (context, state) =>
            _buildPageWithTransition(const NotificationScreen(), state),
      ),
      GoRoute(
        path: AppRoutes.ordersList,
        name: AppRoutes.ordersList,
        pageBuilder: (context, state) =>
            _buildPageWithTransition(const OrdersListScreen(), state),
      ),
      GoRoute(
        path: AppRoutes.addOrder,
        name: AppRoutes.addOrder,
        pageBuilder: (context, state) =>
            _buildPageWithTransition(const AddOrderScreen(), state),
      ),
      GoRoute(
        path: '${AppRoutes.editOrder}/:orderId',
        name: AppRoutes.editOrder,
        pageBuilder: (context, state) {
          final orderId = state.pathParameters['orderId'] ?? '';
          return _buildPageWithTransition(
            EditOrderScreen(orderId: orderId),
            state,
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.orderDetail}/:orderId',
        name: AppRoutes.orderDetail,
        pageBuilder: (context, state) {
          final orderId = state.pathParameters['orderId'] ?? '';
          return _buildPageWithTransition(
            OrderDetailScreen(orderId: orderId),
            state,
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.orderReceipt}/:orderId',
        name: AppRoutes.orderReceipt,
        pageBuilder: (context, state) {
          final orderId = state.pathParameters['orderId'] ?? '';
          return _buildPageWithTransition(
            OrderReceiptScreen(orderId: orderId),
            state,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.customersList,
        name: AppRoutes.customersList,
        pageBuilder: (context, state) =>
            _buildPageWithTransition(const CustomersListScreen(), state),
      ),
      GoRoute(
        path: AppRoutes.addCustomer,
        name: AppRoutes.addCustomer,
        pageBuilder: (context, state) =>
            _buildPageWithTransition(const AddCustomerScreen(), state),
      ),
      GoRoute(
        path: '${AppRoutes.customerDetail}/:customerId',
        name: AppRoutes.customerDetail,
        pageBuilder: (context, state) {
          final customerId = state.pathParameters['customerId'] ?? '';
          return _buildPageWithTransition(
            CustomerDetailScreen(customerId: customerId),
            state,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.measurementsList,
        name: AppRoutes.measurementsList,
        pageBuilder: (context, state) =>
            _buildPageWithTransition(const MeasurementsListScreen(), state),
      ),
      GoRoute(
        path: AppRoutes.addMeasurement,
        name: AppRoutes.addMeasurement,
        pageBuilder: (context, state) =>
            _buildPageWithTransition(const AddMeasurementScreen(), state),
      ),
      GoRoute(
        path: '${AppRoutes.measurementsDetail}/:measurementId',
        name: AppRoutes.measurementsDetail,
        pageBuilder: (context, state) {
          final measurementId = state.pathParameters['measurementId'] ?? '';
          return _buildPageWithTransition(
            MeasurementDetailScreen(measurementId: measurementId),
            state,
          );
        },
      ),
    ],
  ),
);
