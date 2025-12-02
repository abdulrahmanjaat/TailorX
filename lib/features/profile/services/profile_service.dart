import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/services/auth_service.dart';
import '../models/profile_model.dart';
import '../repositories/profile_firestore_repository.dart';

/// Provider for ProfileFirestoreRepository
final profileFirestoreRepositoryProvider = Provider<ProfileFirestoreRepository>(
  (ref) {
    return ProfileFirestoreRepository(firestore: FirebaseFirestore.instance);
  },
);

/// Stream provider for real-time profile updates
///
/// This provider streams profile data from Firestore in real-time.
/// It automatically handles authentication state and returns null when user is not authenticated.
/// The stream automatically refreshes when auth state changes (login/logout).
final profileStreamProvider = StreamProvider<ProfileModel?>((ref) async* {
  // Watch auth state to automatically refresh when user logs in/out
  ref.watch(authStateProvider);

  final repository = ref.watch(profileFirestoreRepositoryProvider);
  final currentUser = FirebaseAuth.instance.currentUser;

  // Wait for user to be authenticated
  if (currentUser == null) {
    yield null;
    return;
  }

  try {
    yield* repository.streamProfile();
  } catch (e) {
    print('Error in profileStreamProvider: $e');
    yield null;
  }
});
