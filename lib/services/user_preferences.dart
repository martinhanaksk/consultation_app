import 'package:shared_preferences/shared_preferences.dart';

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
    if (!prefs.containsKey(key)) return "";

    dynamic value = prefs.get(key);

    return value ?? '';
  }

  Future<void> removeItem(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
