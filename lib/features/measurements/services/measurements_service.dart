import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/measurements_firestore_repository.dart';
import '../../../shared/services/secure_storage_service.dart';

/// Provider for MeasurementsFirestoreRepository
final measurementsFirestoreRepositoryProvider =
    Provider<MeasurementsFirestoreRepository>((ref) {
      return MeasurementsFirestoreRepository(
        firestore: FirebaseFirestore.instance,
        secureStorage: SecureStorageService.instance,
      );
    });
