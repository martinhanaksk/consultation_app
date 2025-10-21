import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const _keyEmail = 'user_email';
  static const _keyRemember = 'remember_me';

  /// Save email and remember preference
  static Future<void> saveUser(String email, bool remember) async {
    final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyEmail, email);
      await prefs.setBool(_keyRemember, true);
    
  }

  /// Get saved email if user opted to remember
  static Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(_keyRemember) ?? false;
    if (remember) {
      return prefs.getString(_keyEmail);
    }
    return null;
  }

  /// Check if user chose "Remember me"
  static Future<bool> isRemembered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRemember) ?? false;
  }

  /// Clear email (log out / forget) TODO
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEmail);
    await prefs.setBool(_keyRemember, false);
  }
}
