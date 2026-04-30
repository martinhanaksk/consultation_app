import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserPreferences {
   final Future<SharedPreferences> _prefsFuture = SharedPreferences.getInstance();
  Future<void> saveItem(String key, dynamic value) async {
    final prefs =await _prefsFuture;

    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    }else if (value is int) {
      await prefs.setInt(key, value);
    } else {
      await prefs.setString(key, value.toString());
    }
  }

   Future<String> getString(String key) async {
    final prefs = await _prefsFuture;
    return prefs.getString(key)??"";
  }

  Future<bool> getBool(String key) async {
    final prefs = await _prefsFuture;
    return prefs.getBool(key)??true;
  }

  Future<int> getInt(String key) async {
    final prefs = await _prefsFuture;
    return prefs.getInt(key)??0;
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
