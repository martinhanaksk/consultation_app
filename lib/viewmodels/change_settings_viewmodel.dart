import 'package:consultation_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class ChangeSettingsViewmodel extends ChangeNotifier {
  String _name = "";
  String _surname = "";
  String _email = "";
  String _token = "";
  String _role = "";
  bool _receiveEmails = false;
  bool get receiveEmails => _receiveEmails;
  String get role => _role;
  String get name => _name;
  String get surname => _surname;
  String get token => _token;
  String get email => _email;
  bool _hasBeenInitialized = false;
  bool get hasBeenInitialized => _hasBeenInitialized;
  void setReceiveEmail(bool? val) {
    _receiveEmails = val ?? false;
    prefs.saveItem('receiveEmails', _receiveEmails);
    notifyListeners();
  }

  Future<void> initialize() async {
    _hasBeenInitialized = true;
    _email = await prefs.getItem("email");
    _token = await prefs.getItem("token");
    UserModel um = await api.getUserByEmail(token, email);
    setReceiveEmail(
      (await prefs.getItem('receiveEmails')),
    );
    _name = um.name;
    _surname = um.surname;
    _role = um.role;
    notifyListeners();
  }
}
