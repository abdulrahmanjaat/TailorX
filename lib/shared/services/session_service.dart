import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for managing session data (temporary, cleared on logout)
class SessionService {
  SessionService._();

  static final SessionService instance = SessionService._();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _sessionStartTimeKey = 'session_start_time';

  /// Record the current session start time
  /// This is called when user opens the app or logs in
  Future<void> startSession() async {
    final now = DateTime.now().toIso8601String();
    await _storage.write(key: _sessionStartTimeKey, value: now);
  }

  /// Get the session start time
  /// Returns null if no session is active
  Future<DateTime?> getSessionStartTime() async {
    final timeString = await _storage.read(key: _sessionStartTimeKey);
    if (timeString == null) {
      return null;
    }
    try {
      return DateTime.parse(timeString);
    } catch (e) {
      return null;
    }
  }

  /// Clear session data (called on logout)
  Future<void> clearSession() async {
    await _storage.delete(key: _sessionStartTimeKey);
  }
}
