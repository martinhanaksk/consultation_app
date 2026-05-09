// session_manager.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz

import 'package:consultation_app/setup.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class SessionManager extends ChangeNotifier {
  // --- Storage keys ---

  static const String _emailKey = 'email';
  static const String _roleKey = 'role';
  static const String _visibilityKey = 'visibility';
  static const String _visitReasonKey = 'visitReason';
  static const String _notifyHoursKey = 'notifyHours';
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
  // empty means no notifications
  List<int> _notifyHours = [];
  String _name = "";
  String _surname = "";
  bool _isLoggedIn = true;
  bool _isLoggingOut = false;

  // --- Getters ---

  String get token => _token;
  String get email => _email;
  String get role => _role;
  bool get visibility => _visibility;
  bool get isDarkModeOn => _isDarkModeOn;
  String get visitReason => _visitReason;
  List<int> get notifyHours => _notifyHours;
  String get name => _name;
  String get surname => _surname;
  bool get isLoggedIn => _isLoggedIn;

  List<int> get notifyHoursList {
    if (_notifyHours.isEmpty) return [];
    return _notifyHours..sort();
  }

  int? _roomIdOwner;
  int? get roomIdOwner => _roomIdOwner;

  int? _roomIdVisitor;
  int? get roomIdVisitor => _roomIdVisitor;

  void resetRoomIdOwner() => _roomIdOwner = null;
  void setRoomIdOwner(int value) => _roomIdOwner = value;
  void setRoomIdVisitor(int value) => _roomIdVisitor = value;

  SessionManager();

  // --- Persistence ---
  // Restores session from storage
  Future<void> load() async {
    _token = await securePrefs.getToken();
    _email = await prefs.getString(_emailKey);
    _role = await prefs.getString(_roleKey);
    _visibility = await prefs.getBool(_visibilityKey);
    _isDarkModeOn = await prefs.getBool('darkMode');
    _visitReason = await prefs.getString(_visitReasonKey);
    String hrs = await prefs.getString(_notifyHoursKey);
    _notifyHours = _decodeHours(hrs);
    _name = await prefs.getString(_nameKey);
    _surname = await prefs.getString(_surnameKey);
    notifyListeners();
  }

  // Persists the full session after successful OTP verification
  Future<void> saveSession(
    String token,
    String email,
    String role,
    bool visibility,
    String visitReason,
    List<int> notifyHours,
    String name,
    String surname,
  ) async {
    final encoded = _encodeHours(notifyHours);
    await securePrefs.saveToken(token);
    await prefs.saveItem(_emailKey, email);
    await prefs.saveItem(_roleKey, role);
    await prefs.saveItem(_visibilityKey, visibility);
    await prefs.saveItem(_visitReasonKey, visitReason);
    await prefs.saveItem(_notifyHoursKey, encoded);
    await prefs.saveItem(_nameKey, name);
    await prefs.saveItem(_surnameKey, surname);
    _token = token;
    _email = email;
    _role = role;
    _visibility = visibility;
    _visitReason = visitReason;
    _notifyHours = notifyHours;
    _name = name;
    _surname = surname;
    _isLoggedIn = true;
    notifyListeners();
  }

  // Wipes all stored and in-memory session data
  Future<void> clear() async {
    await securePrefs.removeToken();
    await prefs.removeItem(_emailKey);
    await prefs.removeItem(_roleKey);
    await prefs.removeItem(_visibilityKey);
    await prefs.removeItem(_visitReasonKey);
    await prefs.removeItem(_notifyHoursKey);
    await prefs.removeItem(_nameKey);
    await prefs.removeItem(_surnameKey);
    _token = "";
    _email = "";
    _role = "";
    _visibility = true;
    _visitReason = "";
    _notifyHours = [];
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

  // Accepts a List<int>, encodes to CSV, persists and updates memory
  Future<void> updateNotifyHours(List<int> hours) async {
    final encoded = _encodeHours(hours);
    await prefs.saveItem(_notifyHoursKey, encoded);
    _notifyHours = hours;
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
  // Prevents duplicate logout calls
  Future<void> checkIfValidToken() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;
    if (_token.isEmpty || JwtDecoder.isExpired(_token)) {
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

  // --- Private helpers ---

  // Encode to string for storing
  String _encodeHours(List<int> hours) {
    final sorted = List<int>.from(hours)..sort();
    return sorted.join(',');
  }

  // Decode to string for use
  List<int> _decodeHours(String hours) {
    if (hours.trim().isEmpty) return [];
    return hours
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .toList()
      ..sort();
  }
}
