import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/profile_firestore_repository.dart';

/// Provider for ProfileFirestoreRepository
final profileFirestoreRepositoryProvider = Provider<ProfileFirestoreRepository>(
  (ref) {
    return ProfileFirestoreRepository(firestore: FirebaseFirestore.instance);
  },
);
