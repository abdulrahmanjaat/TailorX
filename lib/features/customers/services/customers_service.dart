import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
