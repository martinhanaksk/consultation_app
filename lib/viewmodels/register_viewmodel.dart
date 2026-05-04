import 'package:consultation_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class RegisterViewmodel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setIsLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> handleRegisterUser(UserModel um, bool rememberMe) async {
  if (_isLoading) return;
  setIsLoading(true);
  
  try {
    final response = await api.registerUser(um);
    if (response.statusCode == 200) {
      await helpers.handleServer(response, um.email, rememberMe);
      setIsLoading(false); 
    } else {
      notify.showToast('Failed to register user');
      setIsLoading(false);
    }
  } catch (e) {
     notify.showToast('Failed to register user');
    setIsLoading(false);
  }
}
}
