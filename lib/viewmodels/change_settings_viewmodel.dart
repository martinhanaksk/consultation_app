// change_settings_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class ChangeSettingsViewmodel extends ChangeNotifier {
  String _name = "";
  String _surname = "";
  String _email = "";
  String _token = "";
  String _role = "";
  String _visitReason = "";
  bool _receiveEmails = true;
  bool _visibility = true;
  int _notifyHoursBefore = 0;

  bool get receiveEmails => _receiveEmails;
  bool get visibility => _visibility;
  String get role => _role;
  String get name => _name;
  String get surname => _surname;
  String get token => _token;
  String get email => _email;
  String get visitReason => _visitReason;
  int get notifyHoursBefore => _notifyHoursBefore;

  bool _hasBeenInitialized = false;
  bool get hasBeenInitialized => _hasBeenInitialized;

  // -- Setters --

  void setReceiveEmail(bool? val) {
    _receiveEmails = val ?? false;
    prefs.saveItem('receiveEmails', _receiveEmails);
    notifyListeners();
  }

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
        token,
        _name,
        _surname,
        _visitReason,
        newVal,
        _notifyHoursBefore,
      );
      await prefs.saveItem('visibility', newVal);
    } catch (e) {
      _visibility = !newVal;
      notifyListeners();
    }
  }

  Future<void> loadVisibility() async {
    _visibility = await api.getVisibility(token, email);
    await prefs.saveItem('visibility', _visibility);
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
        token,
        newName,
        newSurname,
        _visitReason,
        _visibility,
        _notifyHoursBefore,
      );
      await prefs.saveItem('name', newName);
      await prefs.saveItem('surname', newSurname);
    } catch (e) {
      _name = oldName;
      _surname = oldSurname;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateVisitReason(String reason) async {
    final old = _visitReason;
    _visitReason = reason;
    notifyListeners();
    try {
      await api.updateUserData(
        token,
        _name,
        _surname,
        reason,
        _visibility,
        _notifyHoursBefore,
      );
      await prefs.saveItem('visitReason', reason);
    } catch (e) {
      _visitReason = old;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> createTeacher(String email, String name, String surname) async {
    return await api.createTeacher(_token, email, name, surname);
  }

  Future<void> updateNotifyHoursBefore(int hours) async {
    final old = _notifyHoursBefore;
    _notifyHoursBefore = hours;
    notifyListeners();
    try {
      await api.updateUserData(
        token,
        _name,
        _surname,
        _visitReason,
        _visibility,
        hours,
      );
      await prefs.saveItem('notifyHoursBefore', hours);
    } catch (e) {
      _notifyHoursBefore = old;
      notifyListeners();
    }
  }

  Future<void> initialize() async {
    _hasBeenInitialized = true;
    _email = await prefs.getItem("email");
    _token = await prefs.getItem("token");
    _receiveEmails = (await prefs.getItem('receiveEmails')) ?? true;

    final data = await api.getUserData(_token, _email);

    _name = data['name'] ?? "";
    _surname = data['surname'] ?? "";
    _role = data['role'] ?? "";
    _visitReason = data['visit_reason'] ?? "";
    _visibility = (data['visible'] == 1 || data['visible'] == true);
    _notifyHoursBefore = (data['notification'] as int?) ?? 0;

    await prefs.saveItem('visibility', _visibility);
    await prefs.saveItem('visitReason', _visitReason);
    await prefs.saveItem('notifyHoursBefore', _notifyHoursBefore);

    notifyListeners();
  }
}
