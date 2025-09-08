import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:consultation_app/routes/app_router.dart';

class LoginViewmodel {
  Future<void> continueToVerify(BuildContext context, String email) async {
    final response = await http.post(
      Uri.parse(
        'https://consultations-backend.onrender.com/auth/request-login-otp',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode == 200) {
      Navigator.pushNamed(context, AppRouter.verifyOtp, arguments: email);
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to send OTP. Try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void redirectToRegister(BuildContext context) {
    Navigator.pushNamed(context, AppRouter.register);
  }
}
