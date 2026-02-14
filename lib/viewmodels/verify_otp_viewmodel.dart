import 'package:consultation_app/services/api_service.dart';
import 'package:consultation_app/services/user_preferences.dart';
import 'package:consultation_app/utils/notify_user_utils.dart';
import 'package:consultation_app/views/consultations_student_page.dart';
import 'package:consultation_app/views/consultations_teacher_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:consultation_app/routes/app_router.dart';

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
