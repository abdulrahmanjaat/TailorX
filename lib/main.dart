import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'providers/customer_provider.dart';
import 'providers/language_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/coat_measurement_screen.dart';
import 'screens/customer/customer_detail_screen.dart';
import 'screens/customer/customers_list_screen.dart';
import 'screens/garment_selection_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/kameez_shalwar_screen.dart';
import 'screens/profile/tailor_profile_screen.dart';
import 'screens/settings/privacy_policy_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/sherwani_measurement_screen.dart';
import 'screens/shirt_measurement_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/waistcoat_measurement_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const LahoreDulhaSuitingRoot());
}

class LahoreDulhaSuitingRoot extends StatelessWidget {
  const LahoreDulhaSuitingRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const LahoreDulhaSuitingApp(),
    );
  }
}

class LahoreDulhaSuitingApp extends StatelessWidget {
  const LahoreDulhaSuitingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (context, _) {
        return Consumer<LanguageProvider>(
          builder: (context, languageProvider, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'TailorX',
              theme: AppTheme.lightTheme,
              locale: languageProvider.locale,
              supportedLocales: const [Locale('en'), Locale('ur')],
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              initialRoute: '/splash',
              routes: {
                '/splash': (context) => const PremiumSplashScreen(),
                '/login': (context) => const PremiumLoginScreen(),
                '/signup': (context) => const PremiumSignupScreen(),
                '/reset-password':
                    (context) => const PremiumResetPasswordScreen(),
                '/home': (context) => const TailorHomeScreen(),
                '/customer-details': (context) => const CustomerDetailScreen(),
                '/settings': (context) => const SettingsScreen(),
                '/privacy': (context) => const PrivacyPolicyScreen(),
                '/garment-selection':
                    (context) => const GarmentSelectionScreen(),
                '/customers-list': (context) => const CustomersListScreen(),
                '/tailor-profile': (context) => const TailorProfileScreen(),
                '/shirt-measurement':
                    (context) => const ShirtMeasurementScreen(),
                '/sherwani-measurement':
                    (context) => const SherwaniMeasurementScreen(),
                '/waistcoat-measurement':
                    (context) => const WaistcoatMeasurementScreen(),
                '/coat-measurement': (context) => const CoatMeasurementScreen(),
                '/kameez-shalwar-measurement':
                    (context) => const KameezShalwarMeasurementScreen(),
              },
            );
          },
        );
      },
    );
  }
}
