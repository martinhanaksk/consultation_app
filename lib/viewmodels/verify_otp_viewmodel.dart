import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class VerifyOtpViewmodel extends ChangeNotifier {
  bool _isLoading = false;
  bool isLoading() {
    return _isLoading;
  }

  Future<void> connect(String email, String otp, bool rememberMe) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final success = await api.connect(email, otp, rememberMe);

      if (success) {
        String token = 
      await securePrefs.getToken();
        String role = await prefs.getItem('role');
        helpers.resetLogoutFlag();

        if (role == 'teacher') {
          nav.toOwnerConsultations(token: token, email: email);
        } else if (role == 'student') {
          nav.toBaseConsultations(token: token, email: email);
        }
      } else {
        _isLoading = false;
        notifyListeners();
        notify.showToast('Please enter a valid code.');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      notify.showToast('Connection failed. Please try again.');
    }
  }
}
