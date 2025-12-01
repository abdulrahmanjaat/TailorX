import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  // Note: This will throw an error until you run: flutterfire configure --project=tailorx-jaat001 --android --web
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // If Firebase is not configured, the app will show an error
    // Run: flutterfire configure --project=tailorx-jaat001 --android --web
    print('Firebase initialization error: $e');
    print(
      'Please run: flutterfire configure --project=tailorx-jaat001 --android --web',
    );
  }

  runApp(const ProviderScope(child: TailorXApp()));
}

class TailorXApp extends ConsumerWidget {
  const TailorXApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
