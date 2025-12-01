import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService._();

  static final SecureStorageService instance = SecureStorageService._();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }

  // Auth-specific methods
  Future<void> setLoggedIn(bool value) async {
    await write('isLoggedIn', value.toString());
  }

  Future<bool> isLoggedIn() async {
    final value = await read('isLoggedIn');
    return value == 'true';
  }

  Future<void> setUserId(String userId) async {
    await write('userId', userId);
  }

  Future<String?> getUserId() async {
    return await read('userId');
  }

  Future<void> setUserEmail(String email) async {
    await write('userEmail', email);
  }

  Future<String?> getUserEmail() async {
    return await read('userEmail');
  }

  Future<void> setHasSeenOnboarding(bool value) async {
    await write('hasSeenOnboarding', value.toString());
  }

  Future<bool> hasSeenOnboarding() async {
    final value = await read('hasSeenOnboarding');
    return value == 'true';
  }

  Future<void> setUserName(String name) async {
    await write('userName', name);
  }

  Future<String?> getUserName() async {
    return await read('userName');
  }

  Future<void> setShopName(String shopName) async {
    await write('shopName', shopName);
  }

  Future<String?> getShopName() async {
    return await read('shopName');
  }

  Future<void> setCountryCode(String countryCode) async {
    await write('countryCode', countryCode);
  }

  Future<String?> getCountryCode() async {
    return await read('countryCode');
  }

  /// Clear only auth session data (keeps user profile data like name and shop name)
  Future<void> clearAuthData() async {
    await delete('isLoggedIn');
    await delete('userId');
    await delete('userEmail');
    // Note: userName and shopName are NOT cleared on logout
    // They persist so user can see their data when logging back in
  }

  /// Clear all user data including profile data (used for account deletion)
  Future<void> clearAllUserData() async {
    await delete('isLoggedIn');
    await delete('userId');
    await delete('userEmail');
    await delete('userName');
    await delete('shopName');
    await delete('hasSeenOnboarding');
  }
}
