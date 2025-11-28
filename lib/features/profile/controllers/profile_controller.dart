import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/secure_storage_service.dart';
import '../models/profile_model.dart';

class ProfileController extends StateNotifier<ProfileModel> {
  ProfileController() : super(ProfileModel.defaultProfile) {
    _loadProfile();
  }

  static const String _storageKey = 'user_profile';
  SecureStorageService? _storage;

  Future<void> _initializeStorage() async {
    _storage ??= await SecureStorageService.create();
  }

  Future<void> _loadProfile() async {
    try {
      await _initializeStorage();
      final profileJson = _storage!.read(_storageKey);
      if (profileJson != null) {
        final Map<String, dynamic> json = jsonDecode(profileJson);
        state = ProfileModel.fromJson(json);
      }
    } catch (e) {
      // If loading fails, use default profile
      state = ProfileModel.defaultProfile;
    }
  }

  Future<void> updateProfile(ProfileModel profile) async {
    try {
      await _initializeStorage();
      final profileJson = jsonEncode(profile.toJson());
      await _storage!.write(_storageKey, profileJson);
      state = profile;
    } catch (e) {
      rethrow;
    }
  }
}

final profileProvider = StateNotifierProvider<ProfileController, ProfileModel>(
  (ref) => ProfileController(),
);
