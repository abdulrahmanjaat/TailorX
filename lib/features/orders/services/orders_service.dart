import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/services/auth_service.dart';
import '../models/order_model.dart';
import '../repositories/orders_firestore_repository.dart';
import '../../../shared/services/secure_storage_service.dart';

/// Provider for OrdersFirestoreRepository
final ordersFirestoreRepositoryProvider = Provider<OrdersFirestoreRepository>((
  ref,
) {
  return OrdersFirestoreRepository(
    firestore: FirebaseFirestore.instance,
    secureStorage: SecureStorageService.instance,
  );
});

/// Stream provider for real-time orders
///
/// This provider streams orders from Firestore in real-time.
/// It waits for the user to be authenticated before starting the stream.
/// For new users with no orders, it returns an empty list instead of erroring.
/// The stream automatically refreshes when auth state changes (login/logout).
final ordersStreamProvider = StreamProvider<List<OrderModel>>((ref) async* {
  // Watch auth state to automatically refresh when user logs in/out
  ref.watch(authStateProvider);

  // Check if user is authenticated
  final currentUser = FirebaseAuth.instance.currentUser;

  // If user is not authenticated, return empty list
  if (currentUser == null) {
    yield <OrderModel>[];
    return;
  }

  // User is authenticated, start streaming orders
  final repository = ref.watch(ordersFirestoreRepositoryProvider);
  try {
    yield* repository.streamAllOrders();
  } catch (e) {
    // If there's any error, yield empty list instead of propagating error
    print('Error in ordersStreamProvider: $e');
    yield <OrderModel>[];
  }
});
