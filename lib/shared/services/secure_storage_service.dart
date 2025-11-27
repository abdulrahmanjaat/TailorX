import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  SecureStorageService(this._preferences);

  final SharedPreferences _preferences;

  static Future<SecureStorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SecureStorageService(prefs);
  }

  Future<void> write(String key, String value) async {
    await _preferences.setString(key, value);
  }

  String? read(String key) => _preferences.getString(key);

  Future<void> delete(String key) async {
    await _preferences.remove(key);
  }

  Future<void> clear() async {
    await _preferences.clear();
  }
}
