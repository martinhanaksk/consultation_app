// user_preferences.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Two storage classes:
//   UserPreferences  — plain key-value storage via SharedPreferences
//   SecureUserStorage — encrypted storage via FlutterSecureStorage (tokens only)

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserPreferences {
  // Initialize shared_preferences
  final Future<SharedPreferences> _prefsFuture =
      SharedPreferences.getInstance();

  // Resolves the correct setter at runtime based on the value type;
  // falls back to setString for any unrecognised type
  Future<void> saveItem(String key, dynamic value) async {
    final prefs = await _prefsFuture;

    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else {
      await prefs.setString(key, value.toString());
    }
  }

  // Returns empty string when the key is absent
  Future<String> getString(String key) async {
    final prefs = await _prefsFuture;
    return prefs.getString(key) ?? "";
  }

  // Returns true when the key is absent
  Future<bool> getBool(String key) async {
    final prefs = await _prefsFuture;
    return prefs.getBool(key) ?? true;
  }

  // Returns 0 when the key is absent
  Future<int> getInt(String key) async {
    final prefs = await _prefsFuture;
    return prefs.getInt(key) ?? 0;
  }

  Future<bool> containsItem(String key) async {
    final prefs = await _prefsFuture;
    if (prefs.containsKey(key)) return true;
    return false;
  }

  Future<void> removeItem(String key) async {
    final prefs = await _prefsFuture;
    await prefs.remove(key);
  }
}

class SecureUserStorage {
  static const _tokenKey = 'token';

  // AndroidOptions() uses default keystore — no extra configuration needed on Android
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
  );

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Returns empty string when no token is stored (unauthenticated state)
  Future<String> getToken() async {
    return await _storage.read(key: _tokenKey) ?? "";
  }

  Future<void> removeToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Removes all entries from secure storage
  Future<void> clearAllSecure() async {
    await _storage.deleteAll();
  }
}
