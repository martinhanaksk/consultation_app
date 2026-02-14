import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class VerifyOtpViewmodel {
  Future<void> connect(
    BuildContext context,
    String email,
    String otp,
    bool rememberMe,
  ) async {
    final success = await api.connect(email, otp, rememberMe);
    String token = await prefs.getItem('token');
    String role = await prefs.getItem('role');
    if (success) {
      if (role == 'teacher') {
        nav.toTeacherConsultations(token: token, email: email);
      } else if (role == 'student') {
        nav.toStudentConsultations(token: token, email: email);
      }
    } else {
      notify.showToast('Please enter a valid code.');
    }
  }
}
