import 'package:consultation_app/utils/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:consultation_app/views/welcome_page.dart';
import 'package:consultation_app/routes/app_router.dart';

class VerifyOtpViewmodel {
  Future<void> connect(BuildContext context, String email, String otp) async {
    Dialogs dialogs = Dialogs();

    if (otp == null)
      dialogs.showError(context, 'Type in code from your email.');

    final verifyResponse = await http.post(
      Uri.parse(
        'https://consultations-backend.onrender.com/auth/verify-login-otp',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );

    if (verifyResponse.statusCode == 200) {
      final data = jsonDecode(verifyResponse.body);
      final token = data['token'];
      Navigator.pushNamed(context, AppRouter.welcome, arguments: token);
    } else {
      dialogs.showError(context, 'Invalid OTP');
    }
  }
}
