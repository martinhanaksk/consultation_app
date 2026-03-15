import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
      if (constants.testing) {
        handleTestingServer(response, email, rememberMe);
      } else {
        handleServer(response, email, rememberMe);
      }
    } catch (e) {
      notify.showToast("Please, check your internet connection.");
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

  void handleTestingServer(
    http.Response response,
    String email,
    bool rememberMe,
  ) {
    if (response.statusCode == 200) {
      nav.toVerifyOtp(
        // ← then navigate
        email: email,
        token: response.body,
        rememberMe: rememberMe,
      );
    } else if (response.statusCode == 400) {
      redirectToRegister(email);
    }
  }

  void handleServer(http.Response response, String email, bool rememberMe) {
    if (response.statusCode == 200) {
      nav.toVerifyOtp(email: email, token: "", rememberMe: rememberMe);
    } else if (response.statusCode == 400) {
      redirectToRegister(email);
    } else {
      notify.showToast('Failed to send OTP. Try again.');
    }
  }

  void updateEmail(String value) {
    _email = value;
  }

  void toggleRememberMe(bool? value) {
    _isChecked = value ?? false;
    notifyListeners();
  }

  void redirectToRegister(String email) {
    nav.toRegister(email: email);
  }
}
