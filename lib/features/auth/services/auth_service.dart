import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../../../shared/services/secure_storage_service.dart';

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    firebaseAuth: FirebaseAuth.instance,
    secureStorage: SecureStorageService.instance,
  );
});

/// Provider for current user stream
final authStateProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

/// Provider for current user (synchronous)
final currentUserProvider = Provider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.currentUser;
});

/// Provider for checking if user is logged in
final isLoggedInProvider = FutureProvider<bool>((ref) async {
  final secureStorage = SecureStorageService.instance;
  return await secureStorage.isLoggedIn();
});

/// Provider for checking if user has seen onboarding
final hasSeenOnboardingProvider = FutureProvider<bool>((ref) async {
  final secureStorage = SecureStorageService.instance;
  return await secureStorage.hasSeenOnboarding();
});

