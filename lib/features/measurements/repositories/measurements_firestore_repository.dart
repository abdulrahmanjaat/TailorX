import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/measurement_model.dart';
import '../../../shared/services/secure_storage_service.dart';

class MeasurementsFirestoreRepository {
  MeasurementsFirestoreRepository({
    required this.firestore,
    required this.secureStorage,
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore firestore;
  final SecureStorageService secureStorage;
  final FirebaseAuth _firebaseAuth;

  /// Get the collection path for measurements (scoped to user)
  ///
  /// Returns: users/{uid}/measurements
  ///
  /// IMPORTANT: All measurement data is scoped to the authenticated user's UID.
  /// This ensures:
  /// 1. Users can only see their own measurements
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
    return 'users/${currentUser.uid}/measurements';
  }

  /// Convert MeasurementModel to Firestore Map
  Map<String, dynamic> _toMap(MeasurementModel measurement) {
    return {
      'id': measurement.id,
      'customerId': measurement.customerId,
      'customerName': measurement.customerName,
      'gender': measurement.gender.name, // Convert enum to string
      'orderType': measurement.orderType,
      'values': measurement.values,
      'notes': measurement.notes,
      'createdAt': Timestamp.fromDate(measurement.createdAt),
    };
  }

  /// Convert Firestore Document to MeasurementModel
  MeasurementModel _fromMap(Map<String, dynamic> map) {
    return MeasurementModel(
      id: map['id'] as String,
      customerId: map['customerId'] as String,
      customerName: map['customerName'] as String,
      gender: _parseGender(map['gender'] as String),
      orderType: map['orderType'] as String,
      values: Map<String, double>.from(
        (map['values'] as Map).map(
          (k, v) => MapEntry(k as String, (v as num).toDouble()),
        ),
      ),
      notes: map['notes'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Parse gender string to enum
  MeasurementGender _parseGender(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return MeasurementGender.male;
      case 'female':
        return MeasurementGender.female;
      case 'unisex':
        return MeasurementGender.unisex;
      default:
        return MeasurementGender.male;
    }
  }

  /// Add a new measurement
  Future<void> addMeasurement(MeasurementModel measurement) async {
    final collectionPath = await _getCollectionPath();
    await firestore
        .collection(collectionPath)
        .doc(measurement.id)
        .set(_toMap(measurement));
  }

  /// Update an existing measurement
  Future<void> updateMeasurement(MeasurementModel measurement) async {
    final collectionPath = await _getCollectionPath();
    await firestore
        .collection(collectionPath)
        .doc(measurement.id)
        .update(_toMap(measurement));
  }

  /// Delete a measurement
  Future<void> deleteMeasurement(String measurementId) async {
    final collectionPath = await _getCollectionPath();
    await firestore.collection(collectionPath).doc(measurementId).delete();
  }

  /// Get a measurement by ID
  Future<MeasurementModel?> getMeasurementById(String measurementId) async {
    final collectionPath = await _getCollectionPath();
    final doc = await firestore
        .collection(collectionPath)
        .doc(measurementId)
        .get();
    if (!doc.exists) return null;
    return _fromMap(doc.data()!);
  }

  /// Get all measurements
  Future<List<MeasurementModel>> getAllMeasurements() async {
    final collectionPath = await _getCollectionPath();
    final snapshot = await firestore
        .collection(collectionPath)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => _fromMap(doc.data())).toList();
  }

  /// Get measurements by customer ID
  Future<List<MeasurementModel>> getMeasurementsByCustomerId(
    String customerId,
  ) async {
    final collectionPath = await _getCollectionPath();
    final snapshot = await firestore
        .collection(collectionPath)
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => _fromMap(doc.data())).toList();
  }

  /// Stream all measurements (real-time updates)
  Stream<List<MeasurementModel>> streamAllMeasurements() {
    // Firebase Auth currentUser is REQUIRED for Firestore security rules
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      return Stream.value(<MeasurementModel>[]);
    }

    final collectionPath = 'users/${currentUser.uid}/measurements';
    return firestore
        .collection(collectionPath)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => _fromMap(doc.data())).toList(),
        );
  }
}
