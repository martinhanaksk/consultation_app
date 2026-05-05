// session_manager.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Holds the authenticated user's session state in memory and keeps it
// in sync with persistent storage. Extends ChangeNotifier so any widget
// listening to it rebuilds automatically on session changes.

import 'package:consultation_app/setup.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class SessionManager extends ChangeNotifier {
  // --- Storage keys ---

  static const String _emailKey = 'email';
  static const String _roleKey = 'role';
  static const String _visibilityKey = 'visibility';
  static const String _visitReasonKey = 'visitReason';
  static const String _notifyHoursBeforeKey = 'notifyHoursBefore';
  static const String _nameKey = 'name';
  static const String _surnameKey = 'surname';
  static const String _isDarkModeOnKey = 'darkMode';

  // --- In-memory state ---

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
  // Guards against concurrent logout triggers firing multiple times
  bool _isLoggingOut = false;

  // --- Getters ---

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

  // Last room the teacher had open; used to restore context after navigation
  int? _roomIdOwner;
  int? get roomIdOwner => _roomIdOwner;

  // Last room the student had open; used to restore context after navigation
  int? _roomIdVisitor;
  int? get roomIdVisitor => _roomIdVisitor;

  void resetRoomIdOwner() {
    _roomIdOwner = null;
  }

  void setRoomIdOwner(int value) {
    _roomIdOwner = value;
  }

  void setRoomIdVisitor(int value) {
    _roomIdVisitor = value;
  }

  SessionManager();

  // --- Persistence ---

  // Restores session from storage on app start; called once in main() before runApp
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

  // Persists the full session after successful OTP verification and updates memory
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

  // Wipes all stored and in-memory session data; called on logout or token expiry
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

  // --- Individual field updaters ---

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

  // --- Session validation ---

  // Prevents duplicate logout calls if multiple widgets detect an invalid token simultaneously
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

  // Called on app launch to skip the login screen when a valid, unexpired token exists
  void checkIfInSharedPreferences() async {
    if (sm.role.isNotEmpty && sm.token.isNotEmpty && sm.email.isNotEmpty) {
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
}
