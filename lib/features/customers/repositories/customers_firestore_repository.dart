import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/customer_model.dart';
import '../../../shared/services/secure_storage_service.dart';

class CustomersFirestoreRepository {
  CustomersFirestoreRepository({
    required this.firestore,
    required this.secureStorage,
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore firestore;
  final SecureStorageService secureStorage;
  final FirebaseAuth _firebaseAuth;

  /// Get the collection path for customers (scoped to user)
  ///
  /// Returns: users/{uid}/customers
  ///
  /// IMPORTANT: All customer data is scoped to the authenticated user's UID.
  /// This ensures:
  /// 1. Users can only see their own customers
  /// 2. Data persists across login sessions (data is NOT deleted on logout)
  /// 3. Multi-user isolation - no data leakage between users
  ///
  /// Uses Firebase Auth currentUser as primary source (required for Firestore rules)
  Future<String> _getCollectionPath() async {
    // Firebase Auth currentUser is REQUIRED for Firestore security rules
    // Firestore rules check request.auth.uid, not secure storage
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      // Check if user ID exists in secure storage for better error message
      final userId = await secureStorage.getUserId();
      if (userId != null) {
        throw Exception(
          'Firebase Auth session expired. Please sign in again to continue.',
        );
      }
      throw Exception('User not authenticated. Please sign in to continue.');
    }
    // CRITICAL: Always use user-scoped path - never save at root level
    return 'users/${currentUser.uid}/customers';
  }

  /// Convert CustomerModel to Firestore Map
  Map<String, dynamic> _toMap(CustomerModel customer) {
    return {
      'id': customer.id,
      'name': customer.name,
      'phone': customer.phone,
      'email': customer.email,
      'address': customer.address,
      'createdAt': Timestamp.fromDate(customer.createdAt),
    };
  }

  /// Convert Firestore Document to CustomerModel
  CustomerModel _fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String?,
      address: map['address'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Add a new customer
  Future<void> addCustomer(CustomerModel customer) async {
    final collectionPath = await _getCollectionPath();
    await firestore
        .collection(collectionPath)
        .doc(customer.id)
        .set(_toMap(customer));
  }

  /// Update an existing customer
  Future<void> updateCustomer(CustomerModel customer) async {
    final collectionPath = await _getCollectionPath();
    await firestore
        .collection(collectionPath)
        .doc(customer.id)
        .update(_toMap(customer));
  }

  /// Delete a customer
  Future<void> deleteCustomer(String customerId) async {
    final collectionPath = await _getCollectionPath();
    await firestore.collection(collectionPath).doc(customerId).delete();
  }

  /// Get a customer by ID
  Future<CustomerModel?> getCustomerById(String customerId) async {
    final collectionPath = await _getCollectionPath();
    final doc = await firestore
        .collection(collectionPath)
        .doc(customerId)
        .get();
    if (!doc.exists) return null;
    return _fromMap(doc.data()!);
  }

  /// Get all customers
  Future<List<CustomerModel>> getAllCustomers() async {
    final collectionPath = await _getCollectionPath();
    final snapshot = await firestore
        .collection(collectionPath)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => _fromMap(doc.data())).toList();
  }

  /// Stream all customers (real-time updates)
  Stream<List<CustomerModel>> streamAllCustomers() async* {
    // Firebase Auth currentUser is REQUIRED for Firestore security rules
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      // Return empty stream if not authenticated
      // Firestore rules will deny access anyway, so no point in trying
      yield <CustomerModel>[];
      return;
    }

    final collectionPath = 'users/${currentUser.uid}/customers';
    yield* firestore
        .collection(collectionPath)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => _fromMap(doc.data())).toList(),
        );
  }

  /// Find customer by phone or name
  Future<CustomerModel?> findByPhoneOrName(String phone, String name) async {
    final collectionPath = await _getCollectionPath();
    final phoneTrimmed = phone.trim();
    final nameLower = name.trim().toLowerCase();

    // Query by phone (exact match)
    final phoneQuery = await firestore
        .collection(collectionPath)
        .where('phone', isEqualTo: phoneTrimmed)
        .limit(1)
        .get();

    if (phoneQuery.docs.isNotEmpty) {
      return _fromMap(phoneQuery.docs.first.data());
    }

    // Query by name (case-insensitive search)
    final nameQuery = await firestore.collection(collectionPath).get();

    for (final doc in nameQuery.docs) {
      final data = doc.data();
      final customerName = (data['name'] as String? ?? '').toLowerCase();
      if (customerName == nameLower) {
        return _fromMap(data);
      }
    }

    return null;
  }
}
