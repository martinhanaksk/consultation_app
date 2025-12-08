import 'package:consultation_app/services/apiService.dart';
import 'package:consultation_app/services/userPreferences.dart';
import 'package:consultation_app/utils/notifyUserUtils.dart';
import 'package:consultation_app/views/consultationsStudent_page.dart';
import 'package:consultation_app/views/consultationsTeacher_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:consultation_app/routes/appRouter.dart';

class VerifyOtpViewmodel {
  Future<void> connect(BuildContext context, String email, String otp,bool rememberMe) async {
    NotifyUserUtils dialogs = NotifyUserUtils();
    UserPreferences userPreferences = UserPreferences();
    final ApiService _apiService = ApiService();
    final success = await _apiService.connect(email, otp,rememberMe);
    String? token = await userPreferences.getItem('token');
    String? role = await userPreferences.getItem('role');
    if (success && token != null && role != null) {
      if (role == 'teacher') {
        Navigator.pushNamed(
          context,
          AppRouter.consultationsTeacherPage,
          arguments: ConsultationsTeacherPageArgs(token: token, email: email),
        );
      } else if (role == 'student') {
        Navigator.pushNamed(
          context,
          AppRouter.consultationsStudentPage,
          arguments: ConsultationsStudentPageArgs(token: token, email: email),
        );
      }
    } else {
      dialogs.showToast('Please enter a valid code.');
    }
  }
}
