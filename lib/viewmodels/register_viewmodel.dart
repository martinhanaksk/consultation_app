import 'package:consultation_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class RegisterViewmodel extends ChangeNotifier {
  bool _isLoading = false;

  Future<void> registerUser(UserModel um) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    final token = await api.registerUser(um);
    _isLoading = false;
    notifyListeners();
    if (token != '') {
      nav.toStudentConsultations(token: token, email: um.email);
    } else {
      notify.showToast('Failed to register user. Try again.');
    }
  }
}
