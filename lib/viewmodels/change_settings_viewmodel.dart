import 'package:consultation_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class ChangeSettingsViewmodel extends ChangeNotifier {
  String _name = "";
  String _email = "";
  String _token = "";
  String _role = "";
  String get role => _role;
  String get name => _name;
  String get token => _token;
  String get email => _email;
  bool _hasBeenInitialized = false;
  bool get hasBeenInitialized => _hasBeenInitialized;
  Future<void> initialize() async {
    _hasBeenInitialized = true;
    _email = await prefs.getItem("email");
    _token = await prefs.getItem("token");
    UserModel um = await api.getUserByEmail(token, email);
    _name = um.name;
    _role = um.role;
    notifyListeners();
  }
}
