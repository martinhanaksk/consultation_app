// register_viewmodel.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// ViewModel for the Registration screen. Submits user data to the API and
// delegates post-registration session handling to helpers.handleServer.

import 'package:consultation_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class RegisterViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setIsLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> handleRegisterUser(UserModel um, bool rememberMe) async {
    // Prevent duplicate submissions if the button is tapped while already loading
    if (_isLoading) return;
    setIsLoading(true);

    try {
      final response = await api.registerUser(um);
      if (response?.statusCode == 200) {
        // On success, handleServer is called to redirect to verify page
        await helpers.handleServer(response!, um.email, rememberMe);
        setIsLoading(false);
      } else {
        notify.showToast('Failed to register user', isError: true);
        setIsLoading(false);
      }
    } catch (e) {
      notify.showToast('Failed to register user', isError: true);
      setIsLoading(false);
    }
  }
}
