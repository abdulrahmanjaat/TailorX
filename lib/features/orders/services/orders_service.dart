import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
/// For new users with no orders, it returns an empty list instead of erroring.
final ordersStreamProvider = StreamProvider<List<OrderModel>>((ref) async* {
  final repository = ref.watch(ordersFirestoreRepositoryProvider);
  try {
    yield* repository.streamAllOrders();
  } catch (e) {
    // If there's any error, yield empty list instead of propagating error
    print('Error in ordersStreamProvider: $e');
    yield <OrderModel>[];
  }
});
