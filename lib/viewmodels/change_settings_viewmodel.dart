import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class ChangeSettingsViewmodel extends ChangeNotifier {
  String _name = "";
  String _surname = "";
  String _email = "";
  String _role = "";
  String _visitReason = "";
  bool _visibility = true;
  int _notifyHoursBefore = 0;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool get visibility => _visibility;
  String get role => _role;
  String get name => _name;
  String get surname => _surname;
  String get email => _email;
  String get visitReason => _visitReason;
  int get notifyHoursBefore => _notifyHoursBefore;

  bool _hasBeenInitialized = false;
  bool get hasBeenInitialized => _hasBeenInitialized;

  void setTheme(bool? val) async {
    await themeSelector.setDarkMode(val ?? false);
    notifyListeners();
  }

  void setVisibility() async {
    final newVal = !_visibility;
    _visibility = newVal;
    notifyListeners();
    try {
      await api.updateUserData(
        _name,
        _surname,
        _visitReason,
        newVal,
        _notifyHoursBefore,
      );
      sm.updateVisibility(newVal);
      notify.showToast('Visibility updated');
    } catch (e) {
      _visibility = !newVal;
      notifyListeners();
    }
  }

  Future<void> loadVisibility() async {
    _visibility = await api.getVisibility(email);
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
      await api.updateUserData(
        newName,
        newSurname,
        _visitReason,
        _visibility,
        _notifyHoursBefore,
      );
      sm.updateFullName(newName, newSurname);
      notify.showToast('Name updated');
    } catch (e) {
      _name = oldName;
      _surname = oldSurname;
      notify.showToast('Failed to update name',isError: true);
      notifyListeners();
    }
  }

  Future<void> updateVisitReason(String reason) async {
    final old = _visitReason;
    _visitReason = reason;
    notifyListeners();
    try {
      await api.updateUserData(
        _name,
        _surname,
        reason,
        _visibility,
        _notifyHoursBefore,
      );
      sm.updateVisitReason(reason);
      notify.showToast('Visit reason updated');
    } catch (e) {
      _visitReason = old;
      notify.showToast('Failed to visit reason',isError: true);
      notifyListeners();
    }
  }

  Future<bool> createTeacher(String email, String name, String surname) async {
    return await api.createTeacher(email, name, surname);
  }

  Future<void> updateNotifyHoursBefore(int hours) async {
    final old = _notifyHoursBefore;
    _notifyHoursBefore = hours;
    notifyListeners();
    try {
      await api.updateUserData(
        _name,
        _surname,
        _visitReason,
        _visibility,
        hours,
      );
      sm.updateNotifyHoursBefore(hours);
      notify.showToast('Notification hours updated');
    } catch (e) {
      _notifyHoursBefore = old;
      notifyListeners();
      notify.showToast('Failed to update notification hours', isError: true);
    }
  }

  Future<void> initialize() async {
    if (isLoading) return;
    _isLoading = true;
    notifyListeners();
    _hasBeenInitialized = true;
    _email = sm.email;

    final data = await api.getUserData(sm.token, _email);

    _name = data['name'] ?? "";
    _surname = data['surname'] ?? "";
    _role = data['role'] ?? "";
    _visitReason = data['visit_reason'] ?? "";
    _visibility = (data['visible'] == 1 || data['visible'] == true);
    _notifyHoursBefore = (data['notification'] as int?) ?? 0;

    await sm.saveSession(
      sm.token,
      _email,
      _role,
      _visibility,
      _visitReason,
      _notifyHoursBefore,
      _name,
      _surname,
    );
    _isLoading = false;
    notifyListeners();
  }
}
