// change_settings_viewmodel.dart
// Author: Martin Hanak
// ViewModel for the Settings screen. Loads user profile data, and exposes
// optimistic-update methods for name, visit reason, visibility, and
// notification preferences, each rolling back on API failure.

import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class ChangeSettingsPageViewModel extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────
  String _name = '';
  String _surname = '';
  String _email = '';
  String _role = '';
  String _visitReason = '';
  bool _visibility = true;
  bool _isLoading = false;
  bool _hasBeenInitialized = false;
  List<int> _notifyHours = [];

  // ── Getters ────────────────────────────────────────────────────────────────
  String get name => _name;
  String get surname => _surname;
  String get email => _email;
  String get role => _role;
  String get visitReason => _visitReason;
  bool get visibility => _visibility;
  bool get isLoading => _isLoading;
  bool get hasBeenInitialized => _hasBeenInitialized;
  List<int> get notifyHours => List.unmodifiable(_notifyHours);

  // ── Public Methods ─────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_isLoading) return;
    _setLoading(true);
    _hasBeenInitialized = true;
    _email = sm.email;

    final data = await api.getUserData(sm.token, _email);

    _name = data?['name'] ?? '';
    _surname = data?['surname'] ?? '';
    _role = data?['role'] ?? '';
    _visitReason = data?['visit_reason'] ?? '';
    _visibility = data?['visible'] == 1 || data?['visible'] == true;

    // API returns a list of ints; fall back to empty list if absent
    final raw = data?['notification_times'];
    _notifyHours = raw is List ? List<int>.from(raw.whereType<int>()) : [];

    await sm.saveSession(
      sm.token,
      _email,
      _role,
      _visibility,
      _visitReason,
      _notifyHours,
      _name,
      _surname,
    );
    _setLoading(false);
  }

  Future<void> setTheme(bool? val) async {
    await themeSelector.setDarkMode(val ?? false);
    notifyListeners();
  }

  Future<void> setVisibility() async {
    final newVal = !_visibility;
    _visibility = newVal;
    notifyListeners();
    try {
      await _updateUserData();
      sm.updateVisibility(newVal);
      notify.showToast('Visibility updated');
    } catch (_) {
      _visibility = !newVal;
      notifyListeners();
    }
  }

  Future<void> loadVisibility() async {
    _visibility = await api.getVisibility(_email);
    sm.updateVisibility(_visibility);
    notifyListeners();
  }

  Future<void> updateName(String newName, String newSurname) async {
    final oldName = _name;
    final oldSurname = _surname;
    _name = newName;
    _surname = newSurname;
    notifyListeners();
    try {
      await _updateUserData();
      sm.updateFullName(newName, newSurname);
      notify.showToast('Name updated');
    } catch (_) {
      _name = oldName;
      _surname = oldSurname;
      notifyListeners();
      notify.showToast('Failed to update name', isError: true);
    }
  }

  Future<void> updateVisitReason(String reason) async {
    final old = _visitReason;
    _visitReason = reason;
    notifyListeners();
    try {
      await _updateUserData();
      sm.updateVisitReason(reason);
      notify.showToast('Visit reason updated');
    } catch (_) {
      _visitReason = old;
      notifyListeners();
      notify.showToast('Failed to update visit reason', isError: true);
    }
  }

  Future<void> addNotifyHour(int hours) async {
    if (_notifyHours.contains(hours)) {
      notify.showToast('$hours h is already in the list');
      return;
    }
    _notifyHours = [..._notifyHours, hours]..sort();
    notifyListeners();
    try {
      await api.updateNotificationTimes(_notifyHours);
      sm.updateNotifyHours(_notifyHours);
      notify.showToast('Notification added');
    } catch (_) {
      _notifyHours = List<int>.from(_notifyHours)..remove(hours);
      notifyListeners();
      notify.showToast('Failed to add notification hour', isError: true);
    }
  }

  Future<void> removeNotifyHour(int hours) async {
    final snapshot = List<int>.from(_notifyHours);
    _notifyHours = List<int>.from(_notifyHours)..remove(hours);
    notifyListeners();
    try {
      await api.updateNotificationTimes(_notifyHours);
      sm.updateNotifyHours(_notifyHours);
      notify.showToast('Notification removed');
    } catch (_) {
      _notifyHours = snapshot;
      notifyListeners();
      notify.showToast('Failed to remove notification hour', isError: true);
    }
  }

  Future<bool> createTeacher(String email, String name, String surname) =>
      api.createTeacher(email, name, surname);

  // ── Private Helpers ────────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _updateUserData() => api.updateUserData(
    _name,
    _surname,
    _visitReason,
    _visibility,
    _notifyHours,
  );
}
