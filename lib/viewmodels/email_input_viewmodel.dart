import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class EmailInputViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool _isChecked = false;
  String? _errorMessage;
  String _email = '';
  bool get isLoading => _isLoading;
  bool get isChecked => _isChecked;
  String? get errorMessage => _errorMessage;
  String get email => _email;

  Future<void> continueToVerify(String email, bool rememberMe) async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final response = await api.requestLoginOtp(email);
      helpers.handleServer(response, email, rememberMe);
    } catch (e) {
      notify.showToast("Please, check your internet connection");
      resetLoading();
    }
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void resetLoading() {
    _isLoading = false;
    notifyListeners();
  }

 

  void updateEmail(String value) {
    _email = value;
  }

  void toggleRememberMe(bool? value) {
    _isChecked = value ?? false;
    notifyListeners();
  }

  
}
