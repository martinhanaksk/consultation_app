import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserPreferences {
  Future<void> saveItem(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else {
      await prefs.setString(key, value.toString());
    }
  }

  Future<dynamic> getItem(String key) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.get(key);
  }

  Future<bool> containsItem(String key) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(key)) return true;
    return false;
  }

  Future<void> removeItem(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}

class SecureUserStorage {
  static const _tokenKey = 'token';

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
  );

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String> getToken() async {
    return await _storage.read(key: _tokenKey) ?? "";
  }

  Future<void> removeToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<void> clearAllSecure() async {
    await _storage.deleteAll();
  }
}
