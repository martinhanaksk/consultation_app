import 'package:consultation_app/services/api_service.dart';
import 'package:consultation_app/utils/dialogs.dart';
import 'package:consultation_app/views/consultations_user_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:consultation_app/routes/app_router.dart';

class VerifyOtpViewmodel {
  Future<void> connect(BuildContext context, String email, String otp) async {
    Dialogs dialogs = Dialogs();
    final ApiService _apiService = ApiService();
    final token = await _apiService.connect(email, otp);

    if (token != "") {
      Navigator.pushNamed(
        context,
        AppRouter.cousultationsUserPage,
        arguments: ConsultationsUserPageArgs(token: token, email: email),
      );
    } else {
      dialogs.showErrorDialog(context, 'Invalid OTP');
    }
  }
}
