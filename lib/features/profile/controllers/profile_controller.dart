import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/local_image_storage_service.dart';
import '../../../shared/services/secure_storage_service.dart';
import '../../auth/services/auth_service.dart';
import '../models/profile_model.dart';
import '../repositories/profile_firestore_repository.dart';
import '../services/profile_service.dart';

class ProfileController extends StateNotifier<AsyncValue<ProfileModel>> {
  ProfileController(this._repository) : super(const AsyncValue.loading()) {
    // Clear any cached profile data that doesn't belong to current user
    _validateAndClearCache();
    _loadProfile();
  }

  /// Validate cached profile data and clear if UID doesn't match current user
  Future<void> _validateAndClearCache() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        // No user logged in - clear all cached data
        await _storage.delete(_storageKey);
        await _storage.delete('userName');
        await _storage.delete('shopName');
        await _storage.delete('phone');
        return;
      }

      final currentUserId = currentUser.uid;
      final storedUserId = await _storage.getUserId();

      // If stored user ID doesn't match current user, clear all cached profile data
      if (storedUserId != null && storedUserId != currentUserId) {
        await _storage.delete(_storageKey);
        await _storage.delete('userName');
        await _storage.delete('shopName');
        await _storage.delete('phone');
      } else {
        // Verify cached profile JSON also matches current user
        final profileJson = await _storage.read(_storageKey);
        if (profileJson != null) {
          try {
            final Map<String, dynamic> json = jsonDecode(profileJson);
            final cachedProfile = ProfileModel.fromJson(json);
            if (cachedProfile.uid != currentUserId) {
              // Cached profile belongs to different user - clear it
              await _storage.delete(_storageKey);
              await _storage.delete('userName');
              await _storage.delete('shopName');
              await _storage.delete('phone');
            }
          } catch (_) {
            // Invalid JSON or parsing error - clear cache
            await _storage.delete(_storageKey);
          }
        }
      }
    } catch (_) {
      // Ignore errors during cache validation
    }
  }

  final ProfileFirestoreRepository _repository;
  static const String _storageKey = 'user_profile';
  final SecureStorageService _storage = SecureStorageService.instance;
  void _setStateSafe(AsyncValue<ProfileModel> value) {
    if (mounted) {
      state = value;
    }
  }

  Future<void> _loadProfile() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        // Clear all cached data when no user is logged in
        await _storage.delete(_storageKey);
        await _storage.delete('userName');
        await _storage.delete('shopName');
        await _storage.delete('phone');
        // Don't set error state - just set loading or empty state
        // This prevents showing error UI during logout
        _setStateSafe(const AsyncValue.loading());
        return;
      }

      final currentUserId = currentUser.uid;

      // CRITICAL: Always validate stored user ID matches current user
      // This prevents showing cached data from previous user
      final storedUserId = await _storage.getUserId();
      if (storedUserId != null && storedUserId != currentUserId) {
        // Different user - clear all cached profile data
        await _storage.delete(_storageKey);
        await _storage.delete('userName');
        await _storage.delete('shopName');
        await _storage.delete('phone');
      }

      // First try to load from Firestore (primary source of truth)
      final profile = await _repository.getProfile();
      if (profile != null) {
        // CRITICAL: Verify profile belongs to current user
        if (profile.uid != currentUserId) {
          // Profile UID mismatch - clear cache and reload
          await _storage.delete(_storageKey);
          // Reload from Firestore
          final freshProfile = await _repository.getProfile();
          if (freshProfile != null && freshProfile.uid == currentUserId) {
            final localImagePath = await LocalImageStorageService.instance
                .loadProfileImagePath();
            final profileWithLocalImage = localImagePath != null
                ? freshProfile.copyWith(profileImagePath: localImagePath)
                : freshProfile;
            await _saveToLocalStorage(profileWithLocalImage);
            _setStateSafe(AsyncValue.data(profileWithLocalImage));
            return;
          }
        } else {
          // Profile UID matches - use it
          final localImagePath = await LocalImageStorageService.instance
              .loadProfileImagePath();
          final profileWithLocalImage = localImagePath != null
              ? profile.copyWith(profileImagePath: localImagePath)
              : profile;
          // Save to local storage for offline access
          await _saveToLocalStorage(profileWithLocalImage);
          _setStateSafe(AsyncValue.data(profileWithLocalImage));
          return;
        }
      }

      // Fallback to local storage if Firestore doesn't have profile
      final profileJson = await _storage.read(_storageKey);
      if (profileJson != null) {
        final Map<String, dynamic> json = jsonDecode(profileJson);
        final localProfile = ProfileModel.fromJson(json);

        // CRITICAL: Verify cached profile belongs to current user
        if (localProfile.uid != currentUserId) {
          // Cached profile belongs to different user - clear it
          await _storage.delete(_storageKey);
          await _storage.delete('userName');
          await _storage.delete('shopName');
          await _storage.delete('phone');
        } else {
          // Cached profile matches current user - use it
          final localImagePath = await LocalImageStorageService.instance
              .loadProfileImagePath();
          final profileWithLocalImage = localImagePath != null
              ? localProfile.copyWith(profileImagePath: localImagePath)
              : localProfile;
          _setStateSafe(AsyncValue.data(profileWithLocalImage));
          // Try to save to Firestore if it doesn't exist
          try {
            await _repository.saveProfile(profileWithLocalImage);
          } catch (_) {
            // Ignore Firestore errors, use local data
          }
          return;
        }
      }

      // No profile found anywhere - create default from Firebase Auth data
      final email = currentUser.email ?? '';
      final defaultProfile = ProfileModel.defaultProfile(email, currentUserId);

      // CRITICAL: Only use secure storage data if it belongs to current user
      // AND if Firestore doesn't have a profile (meaning it's truly new)
      // Re-check storedUserId here (in case it was cleared above)
      final storedUserIdCheck = await _storage.getUserId();
      if (storedUserIdCheck == currentUserId) {
        // Double-check: Only use secure storage if Firestore confirmed no profile exists
        // This prevents using stale cached data from previous account
        final name = await _storage.getUserName() ?? '';
        final shopName = await _storage.getShopName() ?? '';
        final phone = await _storage.read('phone') ?? '';

        // Only use secure storage values if they're not empty
        // Empty values mean this is a new account, use defaults
        if (name.isNotEmpty || shopName.isNotEmpty || phone.isNotEmpty) {
          final profileWithDefaults = defaultProfile.copyWith(
            name: name,
            shopName: shopName,
            phone: phone,
          );
          _setStateSafe(AsyncValue.data(profileWithDefaults));
          // Try to save to Firestore
          try {
            await _repository.saveProfile(profileWithDefaults);
          } catch (_) {
            // Ignore Firestore errors
          }
        } else {
          // No data in secure storage - use empty defaults
          _setStateSafe(AsyncValue.data(defaultProfile));
        }
      } else {
        // Stored user ID doesn't match - use empty defaults
        // This should never happen if auth flow is correct, but safety check
        _setStateSafe(AsyncValue.data(defaultProfile));
      }
    } catch (e, stackTrace) {
      // Try to load from local storage as fallback
      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          final profileJson = await _storage.read(_storageKey);
          if (profileJson != null) {
            final Map<String, dynamic> json = jsonDecode(profileJson);
            final localProfile = ProfileModel.fromJson(json);
            // Verify UID matches before using cached data
            if (localProfile.uid == currentUser.uid) {
              final localImagePath = await LocalImageStorageService.instance
                  .loadProfileImagePath();
              final profileWithLocalImage = localImagePath != null
                  ? localProfile.copyWith(profileImagePath: localImagePath)
                  : localProfile;
              _setStateSafe(AsyncValue.data(profileWithLocalImage));
              return;
            }
          }
        }
      } catch (_) {
        // Ignore local storage errors
      }
      _setStateSafe(AsyncValue.error(e, stackTrace));
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
  /// If [imageFile] is provided, it will be saved locally to the device
  /// and the local file path will be stored in the profile.
  /// If [imageFile] is null, the existing profileImagePath will be preserved.
  Future<void> updateProfile(ProfileModel profile, {File? imageFile}) async {
    try {
      ProfileModel profileToSave = profile;

      // If a new image file is provided, save it locally
      if (imageFile != null) {
        try {
          final imagePath = await LocalImageStorageService.instance
              .saveProfileImage(imageFile);
          // Update profile with the local image path
          // Store in profileImagePath field (we'll use this instead of imageUrl)
          profileToSave = profile.copyWith(profileImagePath: imagePath);
        } catch (e) {
          // If save fails, throw error but don't update profile
          throw Exception('Failed to save image: $e');
        }
      } else {
        // If no new image, preserve existing profileImagePath from current state
        final currentProfile = state.value;
        if (currentProfile != null && currentProfile.profileImagePath != null) {
          profileToSave = profile.copyWith(
            profileImagePath: currentProfile.profileImagePath,
          );
        }
      }

      // Save to Firestore first (primary source)
      await _repository.saveProfile(profileToSave);
      // Save to local storage for offline access
      await _saveToLocalStorage(profileToSave);
      _setStateSafe(AsyncValue.data(profileToSave));
    } catch (e, stackTrace) {
      _setStateSafe(AsyncValue.error(e, stackTrace));
      rethrow;
    }
  }

  /// Refresh profile from Firestore
  Future<void> refreshProfile() async {
    _setStateSafe(const AsyncValue.loading());
    await _loadProfile();
  }
}

final profileProvider =
    StateNotifierProvider<ProfileController, AsyncValue<ProfileModel>>((ref) {
      // Watch auth state to refresh profile when user changes
      ref.watch(authStateProvider);
      final controller = ProfileController(
        ref.read(profileFirestoreRepositoryProvider),
      );
      return controller;
    });
