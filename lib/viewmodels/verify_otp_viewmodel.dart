import 'package:consultation_app/utils/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:consultation_app/routes/app_router.dart';

class VerifyOtpViewmodel {
  Future<void> connect(BuildContext context, String email, String otp) async {
    Dialogs dialogs = Dialogs();

    

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
      Navigator.pushNamed(context, AppRouter.cousultationsUserPage, arguments: token);
    } else {
      dialogs.showErrorDialog(context, 'Invalid OTP');
    }
  }
}
