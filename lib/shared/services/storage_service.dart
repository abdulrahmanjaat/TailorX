import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Service for uploading files to Firebase Storage
class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload profile image to Firebase Storage
  ///
  /// Returns the download URL of the uploaded image.
  /// Throws an exception if upload fails.
  ///
  /// The image is stored at: `users/{uid}/profile/profile.jpg`
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated. Please sign in again.');
      }

      // Create a reference to the file location
      final ref = _storage.ref().child(
        'users/${currentUser.uid}/profile/profile.jpg',
      );

      // Upload the file
      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'uploadedAt': DateTime.now().toIso8601String()},
        ),
      );

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw Exception('Failed to upload image: ${e.message}');
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Delete profile image from Firebase Storage
  ///
  /// Throws an exception if deletion fails.
  Future<void> deleteProfileImage() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated. Please sign in again.');
      }

      final ref = _storage.ref().child(
        'users/${currentUser.uid}/profile/profile.jpg',
      );
      await ref.delete();
    } on FirebaseException catch (e) {
      // If file doesn't exist, that's okay
      if (e.code != 'object-not-found') {
        throw Exception('Failed to delete image: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }
}
