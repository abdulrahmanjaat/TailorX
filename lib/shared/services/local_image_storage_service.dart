import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';

/// Service for saving and loading profile images locally on the device
///
/// All images are stored in the app's documents directory and are not
/// uploaded to any backend storage service.
class LocalImageStorageService {
  LocalImageStorageService._();

  static final LocalImageStorageService instance = LocalImageStorageService._();

  /// Get the directory for storing profile images
  Future<Directory> _getProfileImageDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final profileDir = Directory('${directory.path}/profile_images');
    if (!await profileDir.exists()) {
      await profileDir.create(recursive: true);
    }
    return profileDir;
  }

  /// Save profile image to local storage
  ///
  /// Returns the local file path if successful, null otherwise.
  /// Throws an exception if save fails.
  Future<String?> saveProfileImage(File imageFile) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated. Please sign in again.');
      }

      final profileDir = await _getProfileImageDirectory();
      final savedFile = File(
        '${profileDir.path}/profile_${currentUser.uid}.jpg',
      );

      // Copy the image file to the profile directory
      await imageFile.copy(savedFile.path);

      return savedFile.path;
    } catch (e) {
      throw Exception('Failed to save profile image: $e');
    }
  }

  /// Load profile image from local storage
  ///
  /// Returns the file path if the image exists, null otherwise.
  Future<String?> loadProfileImagePath() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return null;
      }

      final profileDir = await _getProfileImageDirectory();
      final imageFile = File(
        '${profileDir.path}/profile_${currentUser.uid}.jpg',
      );

      if (await imageFile.exists()) {
        return imageFile.path;
      }

      return null;
    } catch (e) {
      // Return null on error (image doesn't exist)
      return null;
    }
  }

  /// Delete profile image from local storage
  ///
  /// Throws an exception if deletion fails.
  Future<void> deleteProfileImage() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated. Please sign in again.');
      }

      final profileDir = await _getProfileImageDirectory();
      final imageFile = File(
        '${profileDir.path}/profile_${currentUser.uid}.jpg',
      );

      if (await imageFile.exists()) {
        await imageFile.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete profile image: $e');
    }
  }

  /// Check if profile image exists in local storage
  Future<bool> profileImageExists() async {
    try {
      final path = await loadProfileImagePath();
      return path != null;
    } catch (e) {
      return false;
    }
  }
}
