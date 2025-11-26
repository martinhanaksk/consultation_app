import 'package:consultation_app/models/user_model.dart';
import 'package:consultation_app/services/api_service.dart';
import 'package:consultation_app/utils/notifyUserUtils.dart';
import 'package:consultation_app/views/consultationsStudent_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:consultation_app/routes/app_router.dart';

class RegisterViewmodel {
  NotifyUserUtils dialogs = NotifyUserUtils();
  final ApiService _apiService = ApiService();
  Future<void> registerUser(BuildContext context, UserModel um) async {
    final token = await _apiService.registerUser(um);

    if (token != '') {
      Navigator.pushNamed(
        context,
        AppRouter.consultationsUserPage,
        arguments: ConsultationsUserPageArgs(
    token: token,
    email: um.email,
  ),
      );
    } else {dialogs.showToast('Failed to register user. Try again.');
    }
  }
}
