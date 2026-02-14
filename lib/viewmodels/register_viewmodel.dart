import 'package:consultation_app/models/user_model.dart';
import 'package:consultation_app/services/api_service.dart';
import 'package:consultation_app/utils/notify_user_utils.dart';
import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class RegisterViewmodel {
  NotifyUserUtils dialogs = NotifyUserUtils();
  final ApiService _apiService = ApiService();
  Future<void> registerUser(BuildContext context, UserModel um) async {
    final token = await _apiService.registerUser(um);

    if (token != '') {
       nav.toStudentConsultations(token: token, email: um.email);
      
    } else {
      dialogs.showToast('Failed to register user. Try again.');
    }
  }
}
