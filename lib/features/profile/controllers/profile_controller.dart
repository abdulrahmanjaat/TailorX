import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/secure_storage_service.dart';
import '../../../shared/services/storage_service.dart';
import '../models/profile_model.dart';
import '../repositories/profile_firestore_repository.dart';
import '../services/profile_service.dart';

class ProfileController extends StateNotifier<AsyncValue<ProfileModel>> {
  ProfileController(this._repository) : super(const AsyncValue.loading()) {
    _loadProfile();
  }

  final ProfileFirestoreRepository _repository;
  static const String _storageKey = 'user_profile';
  final SecureStorageService _storage = SecureStorageService.instance;

  Future<void> _loadProfile() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        state = const AsyncValue.error(
          'User not authenticated',
          StackTrace.empty,
        );
        return;
      }

      // First try to load from Firestore (primary source)
      final profile = await _repository.getProfile();
      if (profile != null) {
        // Save to local storage for offline access
        await _saveToLocalStorage(profile);
        state = AsyncValue.data(profile);
        return;
      }

      // Fallback to local storage if Firestore doesn't have profile
      final profileJson = await _storage.read(_storageKey);
      if (profileJson != null) {
        final Map<String, dynamic> json = jsonDecode(profileJson);
        final localProfile = ProfileModel.fromJson(json);
        state = AsyncValue.data(localProfile);
        // Try to save to Firestore if it doesn't exist
        try {
          await _repository.saveProfile(localProfile);
        } catch (_) {
          // Ignore Firestore errors, use local data
        }
      } else {
        // No profile found, create default from Firebase Auth data
        final email = currentUser.email ?? '';
        final defaultProfile = ProfileModel.defaultProfile(
          email,
          currentUser.uid,
        );
        // Try to get name and shopName from secure storage
        final name = await _storage.getUserName() ?? '';
        final shopName = await _storage.getShopName() ?? '';
        final phone = await _storage.read('phone') ?? '';
        final profileWithDefaults = defaultProfile.copyWith(
          name: name,
          shopName: shopName,
          phone: phone,
        );
        state = AsyncValue.data(profileWithDefaults);
        // Try to save to Firestore
        try {
          await _repository.saveProfile(profileWithDefaults);
        } catch (_) {
          // Ignore Firestore errors
        }
      }
    } catch (e, stackTrace) {
      // Try to load from local storage as fallback
      try {
        final profileJson = await _storage.read(_storageKey);
        if (profileJson != null) {
          final Map<String, dynamic> json = jsonDecode(profileJson);
          state = AsyncValue.data(ProfileModel.fromJson(json));
          return;
        }
      } catch (_) {
        // Ignore local storage errors
      }
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> _saveToLocalStorage(ProfileModel profile) async {
    try {
      final profileJson = jsonEncode(profile.toJson());
      await _storage.write(_storageKey, profileJson);
      // Also save individual fields for backward compatibility
      await _storage.setUserName(profile.name);
      await _storage.setShopName(profile.shopName);
      if (profile.phone.isNotEmpty) {
        await _storage.write('phone', profile.phone);
      }
    } catch (_) {
      // Ignore storage errors
    }
  }

  /// Update profile with optional image file
  ///
  /// If [imageFile] is provided, it will be uploaded to Firebase Storage
  /// and the download URL will be saved to Firestore.
  /// If [imageFile] is null, the existing imageUrl will be preserved.
  Future<void> updateProfile(ProfileModel profile, {File? imageFile}) async {
    try {
      ProfileModel profileToSave = profile;

      // If a new image file is provided, upload it to Firebase Storage
      if (imageFile != null) {
        try {
          final imageUrl = await StorageService.instance.uploadProfileImage(
            imageFile,
          );
          // Update profile with the new image URL
          profileToSave = profile.copyWith(imageUrl: imageUrl);
        } catch (e) {
          // If upload fails, throw error but don't update profile
          throw Exception('Failed to upload image: $e');
        }
      } else {
        // If no new image, preserve existing imageUrl from current state
        final currentProfile = state.value;
        if (currentProfile != null && currentProfile.imageUrl != null) {
          profileToSave = profile.copyWith(imageUrl: currentProfile.imageUrl);
        }
      }

      // Save to Firestore first (primary source)
      await _repository.saveProfile(profileToSave);
      // Save to local storage for offline access
      await _saveToLocalStorage(profileToSave);
      state = AsyncValue.data(profileToSave);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Refresh profile from Firestore
  Future<void> refreshProfile() async {
    state = const AsyncValue.loading();
    await _loadProfile();
  }
}

final profileProvider =
    StateNotifierProvider<ProfileController, AsyncValue<ProfileModel>>(
      (ref) => ProfileController(ref.read(profileFirestoreRepositoryProvider)),
    );
