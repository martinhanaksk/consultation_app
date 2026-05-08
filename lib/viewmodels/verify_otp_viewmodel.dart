// verify_otp_viewmodel.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// ViewModel for the OTP verification screen. Submits the email + OTP pair,
// loads the session on success, and routes to the correct home screen based
// on the user's role.

import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class VerifyOtpViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool isLoading() {
    return _isLoading;
  }

  Future<void> connect(String email, String otp, bool rememberMe) async {
    // Prevent duplicate OTP submissions while a request is already in progress
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    try {
      final success = await api.connect(email, otp, rememberMe);

      if (success) {
        // Reload session so role and token are available for the routing decision below
        await sm.load();
        if (sm.role == 'teacher') {
          nav.toOwnerConsultations();
        } else if (sm.role == 'student') {
          nav.toBaseConsultations();
        }
      } else {
        _isLoading = false;
        notifyListeners();
        notify.showToast('Please enter a valid code');
      }
    } catch (e, stacktrace) {
      _isLoading = false;
      notifyListeners();
      print(e);
      print(stacktrace);
      notify.showToast(
        'Connection failed, please try again later',
        isError: true,
      );
    }
  }
}
