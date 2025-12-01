import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/profile_model.dart';

class ProfileFirestoreRepository {
  ProfileFirestoreRepository({
    required this.firestore,
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore firestore;
  final FirebaseAuth _firebaseAuth;

  /// Get the user document path
  ///
  /// Returns: users/{uid}
  ///
  /// IMPORTANT: Profile data is stored at users/{uid} (not in a subcollection).
  /// This ensures:
  /// 1. Users can only access their own profile
  /// 2. Profile data persists across login sessions (data is NOT deleted on logout)
  /// 3. Multi-user isolation - no data leakage between users
  String _getUserPath() {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated. Please sign in again.');
    }
    // CRITICAL: Always use user-scoped path - never save at root level
    return 'users/${currentUser.uid}';
  }

  /// Convert ProfileModel to Firestore Map
  Map<String, dynamic> _toMap(ProfileModel profile) {
    return {
      'name': profile.name,
      'shopName': profile.shopName,
      'phone': profile.phone,
      'email': profile.email,
      'uid': profile.uid,
      'profileImagePath': profile.profileImagePath,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Convert Firestore Document to ProfileModel
  ProfileModel _fromMap(Map<String, dynamic> map, String uid) {
    return ProfileModel(
      name: map['name'] as String? ?? '',
      shopName: map['shopName'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      uid: uid,
      profileImagePath: map['profileImagePath'] as String?,
    );
  }

  /// Create or update user profile
  Future<void> saveProfile(ProfileModel profile) async {
    final userPath = _getUserPath();
    await firestore.doc(userPath).set(_toMap(profile), SetOptions(merge: true));
  }

  /// Get user profile
  Future<ProfileModel?> getProfile() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      return null;
    }

    final userPath = 'users/${currentUser.uid}';
    final doc = await firestore.doc(userPath).get();
    if (!doc.exists) {
      return null;
    }

    final data = doc.data();
    if (data == null) {
      return null;
    }

    return _fromMap(data, currentUser.uid);
  }

  /// Stream user profile (real-time updates)
  Stream<ProfileModel?> streamProfile() {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      return Stream.value(null);
    }

    final userPath = 'users/${currentUser.uid}';
    return firestore.doc(userPath).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      final data = snapshot.data();
      if (data == null) {
        return null;
      }
      return _fromMap(data, currentUser.uid);
    });
  }
}
