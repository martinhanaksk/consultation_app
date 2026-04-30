import 'package:consultation_app/setup.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
class SessionManager extends ChangeNotifier {
  static const String _emailKey = 'email';
  static const String _roleKey = 'role';
  static const String _visibilityKey = 'visibility';
  static const String _visitReasonKey = 'visitReason';
  static const String _notifyHoursBeforeKey = 'notifyHoursBefore';
  static const String _nameKey = 'name';
  static const String _surnameKey = 'surname';
  static const String _isDarkModeOnKey = 'darkMode';

  String _token = "";
  String _email = "";
  String _role = "";
  bool _visibility = true;
  bool _isDarkModeOn = false;
  String _visitReason = "";
  int _notifyHoursBefore = 0;
  String _name = "";
  String _surname = "";
  bool _isLoggedIn = true;
  String get token => _token;
  String get email => _email;
  String get role => _role;
  bool get visibility => _visibility;
  bool get isDarkModeOn => _isDarkModeOn;
  String get visitReason => _visitReason;
  int get notifyHoursBefore => _notifyHoursBefore;
  String get name => _name;
  String get surname => _surname;
  bool get isLoggedIn => _isLoggedIn;
  bool _isLoggingOut = false;
  SessionManager();

  Future<void> load() async {
    _token = await securePrefs.getToken();
    _email = await prefs.getString(_emailKey);
    _role = await prefs.getString(_roleKey);
    _visibility = await prefs.getBool(_visibilityKey);
    _isDarkModeOn = await prefs.getBool('darkMode');
    _visitReason = await prefs.getString(_visitReasonKey);
    _notifyHoursBefore = await prefs.getInt(_notifyHoursBeforeKey);
    _name = await prefs.getString(_nameKey);
    _surname = await prefs.getString(_surnameKey);
    notifyListeners();
  }

  Future<void> saveSession(
    String token,
    String email,
    String role,
    bool visibility,
    String visitReason,
    int notifyHoursBefore,
    String name,
    String surname,
  ) async {
    await securePrefs.saveToken(token);
    await prefs.saveItem(_emailKey, email);
    await prefs.saveItem(_roleKey, role);
    await prefs.saveItem(_visibilityKey, visibility);
    await prefs.saveItem(_visitReasonKey, visitReason);
    await prefs.saveItem(_notifyHoursBeforeKey, notifyHoursBefore);
    await prefs.saveItem(_nameKey, name);
    await prefs.saveItem(_surnameKey, surname);
    _token = token;
    _email = email;
    _role = role;
    _visibility = visibility;
    _visitReason = visitReason;
    _notifyHoursBefore = notifyHoursBefore;
    _name = name;
    _surname = surname;
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> updateToken(String token) async {
    await securePrefs.saveToken(token);
    _token = token;
    notifyListeners();
  }

  Future<void> updateEmail(String email) async {
    await prefs.saveItem(_emailKey, email);
    _email = email;
    notifyListeners();
  }

  Future<void> updateRole(String role) async {
    await prefs.saveItem(_roleKey, role);
    _role = role;
    notifyListeners();
  }

  Future<void> updateVisibility(bool visibility) async {
    await prefs.saveItem(_visibilityKey, visibility);
    _visibility = visibility;
    notifyListeners();
  }

  Future<void> updateIsDarkModeOn(bool isDarkModeOn) async {
    await prefs.saveItem(_isDarkModeOnKey, isDarkModeOn);
    _isDarkModeOn = isDarkModeOn;
    notifyListeners();
  }

  Future<void> updateVisitReason(String visitReason) async {
    await prefs.saveItem(_visitReasonKey, visitReason);
    _visitReason = visitReason;
    notifyListeners();
  }

  Future<void> updateNotifyHoursBefore(int hours) async {
    await prefs.saveItem(_notifyHoursBeforeKey, hours);
    _notifyHoursBefore = hours;
    notifyListeners();
  }

  Future<void> updateName(String name) async {
    await prefs.saveItem(_nameKey, name);
    _name = name;
    notifyListeners();
  }

  Future<void> updateSurname(String surname) async {
    await prefs.saveItem(_surnameKey, surname);
    _surname = surname;
    notifyListeners();
  }

  Future<void> updateFullName(String name, String surname) async {
    await prefs.saveItem(_nameKey, name);
    await prefs.saveItem(_surnameKey, surname);
    _name = name;
    _surname = surname;
    notifyListeners();
  }

  Future<void> checkIfValidToken() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;
    if (sm.token == "") {
      sm.clear();
      nav.toLogin();
    }
    Future.delayed(Duration(seconds: 2), () {
      _isLoggingOut = false;
    });
  }

  void checkIfInSharedPreferences() async {
    if (
        sm.role.isNotEmpty &&
        sm.token.isNotEmpty &&
        sm.email.isNotEmpty) {
      bool isExpired = JwtDecoder.isExpired(sm.token);

      if (!isExpired) {
        if (sm.role == 'teacher') {
          nav.toOwnerConsultations();
        } else if (sm.role == 'student') {
          nav.toBaseConsultations();
        }
      } else {
        sm.clear();
      }
    }
  }

  Future<void> clear() async {
    await securePrefs.removeToken();
    await prefs.removeItem(_emailKey);
    await prefs.removeItem(_roleKey);
    await prefs.removeItem('visibility');
    await prefs.removeItem('visitReason');
    await prefs.removeItem('notifyHoursBefore');
    await prefs.removeItem('name');
    await prefs.removeItem('surname');
    _token = "";
    _email = "";
    _role = "";
    _visibility = true;
    _visitReason = "";
    _notifyHoursBefore = 0;
    _name = "";
    _surname = "";
    _isLoggedIn = false;
    notifyListeners();
  }
}
