import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/customer.dart';
import '../models/measurement_model.dart';
import 'auth_service.dart';

class FirestoreService {
  FirestoreService({
    FirebaseFirestore? firestore,
    AuthService? authService,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _authService = authService ?? AuthService();

  final FirebaseFirestore _db;
  final AuthService _authService;

  Future<bool> phoneExists(String phone, {String? excludeCustomerId}) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return false;
    final query = await _db
        .collection('users')
        .doc(userId)
        .collection('customers')
        .where('phone', isEqualTo: phone)
        .limit(5)
        .get();

    for (final doc in query.docs) {
      if (excludeCustomerId == null || doc.id != excludeCustomerId) {
        return true;
      }
    }
    return false;
  }

  Future<void> addCustomer(Customer customer) async {
    try {
      await _db
          .collection('users')
          .doc(customer.userId)
          .collection('customers')
          .doc(customer.id)
          .set({
        'id': customer.id,
        'name': customer.name,
        'phone': customer.phone,
        'address': customer.address,
        'createdAt': customer.createdAt.toIso8601String(),
        'lastOrderDate': customer.lastOrderDate?.toIso8601String(),
        'userId': customer.userId,
      }, SetOptions(merge: true));
    } catch (e, stackTrace) {
      debugPrint('Failed to add customer: $e');
      Error.throwWithStackTrace(e, stackTrace);
    }
  }

  Stream<List<Customer>> getCustomers() {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      return const Stream.empty();
    }
    return _db
        .collection('users')
        .doc(userId)
        .collection('customers')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return Customer(
            id: data['id'],
            name: data['name'],
            phone: data['phone'],
            address: data['address'] ?? '',
            measurements: const [],
            createdAt: DateTime.parse(data['createdAt']),
            lastOrderDate: data['lastOrderDate'] != null
                ? DateTime.parse(data['lastOrderDate'])
                : null,
            userId: data['userId'],
          );
        }).toList();
      },
    );
  }

  Future<void> addMeasurement(
    Measurement measurement, {
    SectionedMeasurement? sectionedMeasurement,
  }) async {
    try {
      await _db
          .collection('users')
          .doc(measurement.userId)
          .collection('customers')
          .doc(measurement.customerId)
          .collection('measurements')
          .doc(measurement.id)
          .set({
        'id': measurement.id,
        'garmentType': measurement.garmentType,
        'customerName': measurement.customerName,
        'phone': measurement.phone,
        'measurements': measurement.measurements,
        'additionalDetails': measurement.additionalDetails,
        'designNotes': measurement.designNotes,
        'createdAt': measurement.createdAt.toIso8601String(),
        'deliveryDate': measurement.deliveryDate.toIso8601String(),
        'customerId': measurement.customerId,
        'userId': measurement.userId,
        if (sectionedMeasurement != null)
          'sectionedMeasurement': sectionedMeasurement.toMap(),
      }, SetOptions(merge: true));
    } catch (e, stackTrace) {
      debugPrint('Failed to add measurement: $e');
      Error.throwWithStackTrace(e, stackTrace);
    }
  }

  Stream<List<Measurement>> getMeasurements(String customerId) {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      throw StateError('User not logged in');
    }
    if (customerId.isEmpty) {
      throw ArgumentError('Customer ID is required');
    }
    return _db
        .collection('users')
        .doc(userId)
        .collection('customers')
        .doc(customerId)
        .collection('measurements')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(
              (doc) => Measurement.fromMap(doc.data()),
            )
            .toList());
  }

  Stream<Customer> getCustomerById(String customerId) {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      throw StateError('User not logged in');
    }
    return _db
        .collection('users')
        .doc(userId)
        .collection('customers')
        .doc(customerId)
        .snapshots()
        .map((doc) {
      final data = doc.data();
      if (data == null) {
        throw StateError('Customer not found');
      }
      return Customer(
        id: data['id'],
        name: data['name'],
        phone: data['phone'],
        address: data['address'] ?? '',
        measurements: const [],
        createdAt: DateTime.parse(data['createdAt']),
        lastOrderDate: data['lastOrderDate'] != null
            ? DateTime.parse(data['lastOrderDate'])
            : null,
        userId: data['userId'],
      );
    });
  }

  Future<void> deleteCustomer(String userId, String customerId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('customers')
        .doc(customerId)
        .delete();
  }
}

