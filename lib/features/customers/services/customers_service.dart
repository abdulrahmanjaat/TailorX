import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/services/auth_service.dart';
import '../models/customer_model.dart';
import '../repositories/customers_firestore_repository.dart';
import '../../../shared/services/secure_storage_service.dart';

/// Provider for CustomersFirestoreRepository
final customersFirestoreRepositoryProvider =
    Provider<CustomersFirestoreRepository>((ref) {
      return CustomersFirestoreRepository(
        firestore: FirebaseFirestore.instance,
        secureStorage: SecureStorageService.instance,
      );
    });

/// Stream provider for real-time customers
///
/// This provider streams customers from Firestore in real-time.
/// It automatically refreshes when auth state changes (login/logout).
/// For new users with no customers, it returns an empty list.
final customersStreamProvider = StreamProvider<List<CustomerModel>>((
  ref,
) async* {
  // Watch auth state to automatically refresh when user logs in/out
  ref.watch(authStateProvider);

  // Check if user is authenticated
  final currentUser = FirebaseAuth.instance.currentUser;

  // If user is not authenticated, return empty list
  if (currentUser == null) {
    yield <CustomerModel>[];
    return;
  }

  // User is authenticated, start streaming customers
  final repository = ref.watch(customersFirestoreRepositoryProvider);
  try {
    yield* repository.streamAllCustomers();
  } catch (e) {
    // If there's any error, yield empty list instead of propagating error
    print('Error in customersStreamProvider: $e');
    yield <CustomerModel>[];
  }
});
