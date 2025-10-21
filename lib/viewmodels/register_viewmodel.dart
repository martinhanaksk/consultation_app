import 'package:consultation_app/models/user_model.dart';
import 'package:consultation_app/services/api_service.dart';
import 'package:consultation_app/utils/dialogs.dart';
import 'package:consultation_app/views/consultations_user_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:consultation_app/routes/app_router.dart';

class RegisterViewmodel {
  Dialogs dialogs = Dialogs();
  final ApiService _apiService = ApiService();
  Future<void> registerUser(BuildContext context, UserModel um) async {
    final token = await _apiService.registerUser(um);

    if (token != '') {
      Navigator.pushNamed(
        context,
        AppRouter.cousultationsUserPage,
        arguments: ConsultationsUserPageArgs(
    token: token,
    email: um.email,
  ),
      );
    } else {
      dialogs.showErrorDialog(context, 'Failed to register user. Try again.');
    }
  }
}
