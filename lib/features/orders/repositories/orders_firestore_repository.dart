import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart';
import '../models/order_item_model.dart';
import '../../../shared/services/secure_storage_service.dart';

class OrdersFirestoreRepository {
  OrdersFirestoreRepository({
    required this.firestore,
    required this.secureStorage,
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore firestore;
  final SecureStorageService secureStorage;
  final FirebaseAuth _firebaseAuth;

  /// Get the collection path for orders (scoped to user)
  ///
  /// Returns: users/{uid}/orders
  ///
  /// IMPORTANT: All order data is scoped to the authenticated user's UID.
  /// This ensures:
  /// 1. Users can only see their own orders
  /// 2. Data persists across login sessions (data is NOT deleted on logout)
  /// 3. Multi-user isolation - no data leakage between users
  ///
  /// Uses Firebase Auth currentUser as primary source (required for Firestore rules)
  Future<String> _getCollectionPath() async {
    // Firebase Auth currentUser is REQUIRED for Firestore security rules
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      // Fallback to secure storage for better error message
      final userId = await secureStorage.getUserId();
      if (userId != null) {
        throw Exception(
          'Firebase Auth session expired. Please sign in again to continue.',
        );
      }
      throw Exception('User not authenticated. Please sign in to continue.');
    }
    // CRITICAL: Always use user-scoped path - never save at root level
    return 'users/${currentUser.uid}/orders';
  }

  /// Convert OrderItem to Firestore Map
  Map<String, dynamic> _itemToMap(OrderItem item) {
    return {
      'orderType': item.orderType,
      'quantity': item.quantity,
      'unitPrice': item.unitPrice,
      'measurementId': item.measurementId,
      'measurementMap': item.measurementMap.map((k, v) => MapEntry(k, v)),
    };
  }

  /// Convert Firestore Map to OrderItem
  OrderItem _itemFromMap(Map<String, dynamic> map) {
    return OrderItem(
      orderType: map['orderType'] as String,
      quantity: map['quantity'] as int,
      unitPrice: (map['unitPrice'] as num).toDouble(),
      measurementId: map['measurementId'] as String?,
      measurementMap: Map<String, double>.from(
        (map['measurementMap'] as Map).map(
          (k, v) => MapEntry(k as String, (v as num).toDouble()),
        ),
      ),
    );
  }

  /// Convert OrderModel to Firestore Map
  Map<String, dynamic> _toMap(OrderModel order) {
    return {
      'id': order.id,
      'customerId': order.customerId,
      'customerName': order.customerName,
      'items': order.items.map((item) => _itemToMap(item)).toList(),
      'gender': order.gender,
      'deliveryDate': Timestamp.fromDate(order.deliveryDate),
      'createdAt': Timestamp.fromDate(order.createdAt),
      'status': order.status.name, // Convert enum to string
      'totalAmount': order.totalAmount,
      'advanceAmount': order.advanceAmount,
      'notes': order.notes,
    };
  }

  /// Convert Firestore Document to OrderModel
  OrderModel _fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] as String,
      customerId: map['customerId'] as String,
      customerName: map['customerName'] as String,
      items: (map['items'] as List)
          .map((item) => _itemFromMap(item as Map<String, dynamic>))
          .toList(),
      gender: map['gender'] as String,
      deliveryDate: (map['deliveryDate'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      status: _parseStatus(map['status'] as String),
      totalAmount: (map['totalAmount'] as num).toDouble(),
      advanceAmount: (map['advanceAmount'] as num).toDouble(),
      notes: map['notes'] as String?,
    );
  }

  /// Parse status string to enum
  OrderStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'neworder':
        return OrderStatus.newOrder;
      case 'inprogress':
        return OrderStatus.inProgress;
      case 'completed':
        return OrderStatus.completed;
      default:
        return OrderStatus.newOrder;
    }
  }

  /// Add a new order
  Future<void> addOrder(OrderModel order) async {
    final collectionPath = await _getCollectionPath();
    await firestore.collection(collectionPath).doc(order.id).set(_toMap(order));
  }

  /// Update an existing order
  Future<void> updateOrder(OrderModel order) async {
    final collectionPath = await _getCollectionPath();
    await firestore
        .collection(collectionPath)
        .doc(order.id)
        .update(_toMap(order));
  }

  /// Delete an order
  Future<void> deleteOrder(String orderId) async {
    final collectionPath = await _getCollectionPath();
    await firestore.collection(collectionPath).doc(orderId).delete();
  }

  /// Get an order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    final collectionPath = await _getCollectionPath();
    final doc = await firestore.collection(collectionPath).doc(orderId).get();
    if (!doc.exists) return null;
    return _fromMap(doc.data()!);
  }

  /// Get all orders
  Future<List<OrderModel>> getAllOrders() async {
    final collectionPath = await _getCollectionPath();
    final snapshot = await firestore
        .collection(collectionPath)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => _fromMap(doc.data())).toList();
  }

  /// Get orders by customer ID
  Future<List<OrderModel>> getOrdersByCustomerId(String customerId) async {
    final collectionPath = await _getCollectionPath();
    final snapshot = await firestore
        .collection(collectionPath)
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => _fromMap(doc.data())).toList();
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final collectionPath = await _getCollectionPath();
    await firestore.collection(collectionPath).doc(orderId).update({
      'status': status.name,
    });
  }

  /// Stream all orders (real-time updates)
  Stream<List<OrderModel>> streamAllOrders() async* {
    // Firebase Auth currentUser is REQUIRED for Firestore security rules
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      yield <OrderModel>[];
      return;
    }

    final collectionPath = 'users/${currentUser.uid}/orders';
    try {
      yield* firestore
          .collection(collectionPath)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            try {
              return snapshot.docs
                  .map((doc) {
                    try {
                      return _fromMap(doc.data());
                    } catch (e) {
                      print('Error parsing order document ${doc.id}: $e');
                      return null;
                    }
                  })
                  .whereType<OrderModel>()
                  .toList();
            } catch (e) {
              print('Error processing order snapshot: $e');
              return <OrderModel>[];
            }
          })
          .handleError((error, stackTrace) {
            // Log error but continue - will be caught by outer try-catch
            print('Error in orders stream: $error');
          });
    } catch (e) {
      // Catch any errors during stream setup (e.g., permission denied, collection doesn't exist)
      // Return empty list instead of throwing - this handles new users gracefully
      print('Error setting up orders stream: $e');
      yield <OrderModel>[];
    }
  }
}
