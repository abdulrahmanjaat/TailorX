import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
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
import '../../features/orders/screens/order_detail_screen.dart';
import '../../features/orders/screens/order_receipt_screen.dart';
import '../../features/orders/screens/orders_list_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/terms_privacy_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        name: AppRoutes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.termsPrivacy,
        name: AppRoutes.termsPrivacy,
        builder: (context, state) => const TermsPrivacyScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: AppRoutes.notifications,
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.ordersList,
        name: AppRoutes.ordersList,
        builder: (context, state) => const OrdersListScreen(),
      ),
      GoRoute(
        path: AppRoutes.addOrder,
        name: AppRoutes.addOrder,
        builder: (context, state) => const AddOrderScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.orderDetail}/:orderId',
        name: AppRoutes.orderDetail,
        builder: (context, state) {
          final orderId = state.pathParameters['orderId'] ?? '';
          return OrderDetailScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '${AppRoutes.orderReceipt}/:orderId',
        name: AppRoutes.orderReceipt,
        builder: (context, state) {
          final orderId = state.pathParameters['orderId'] ?? '';
          return OrderReceiptScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: AppRoutes.customersList,
        name: AppRoutes.customersList,
        builder: (context, state) => const CustomersListScreen(),
      ),
      GoRoute(
        path: AppRoutes.addCustomer,
        name: AppRoutes.addCustomer,
        builder: (context, state) => const AddCustomerScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.customerDetail}/:customerId',
        name: AppRoutes.customerDetail,
        builder: (context, state) {
          final customerId = state.pathParameters['customerId'] ?? '';
          return CustomerDetailScreen(customerId: customerId);
        },
      ),
      GoRoute(
        path: AppRoutes.measurementsList,
        name: AppRoutes.measurementsList,
        builder: (context, state) => const MeasurementsListScreen(),
      ),
      GoRoute(
        path: AppRoutes.addMeasurement,
        name: AppRoutes.addMeasurement,
        builder: (context, state) => const AddMeasurementScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.measurementsDetail}/:measurementId',
        name: AppRoutes.measurementsDetail,
        builder: (context, state) {
          final measurementId = state.pathParameters['measurementId'] ?? '';
          return MeasurementDetailScreen(measurementId: measurementId);
        },
      ),
    ],
  ),
);
