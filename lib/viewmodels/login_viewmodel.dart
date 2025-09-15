import 'package:consultation_app/utils/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:consultation_app/routes/app_router.dart';

class LoginViewmodel {
  Dialogs dialogs = Dialogs();
  Future<void> continueToVerify(BuildContext context, String email) async {
    dialogs.showLoadingDialog(context, "Sending OTP...");
    try {
      final response = await http.post(
        Uri.parse(
          'https://consultations-backend.onrender.com/auth/request-login-otp/',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      if (response.statusCode == 200) {
        //Navigator.pop(context);
        Navigator.pushNamed(context, AppRouter.verifyOtp, arguments: email);
      } else if (response.statusCode == 307) {
        // Handle redirect manually
        String? location = response.headers['location'];
        if (location != null) {
          final redirectResponse = await http
              .post(
                Uri.parse(location),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
                body: jsonEncode({'email': email.trim()}),
              )
              .timeout(Duration(seconds: 30));

          if (redirectResponse.statusCode == 200) {
            Navigator.pushNamed(context, AppRouter.verifyOtp, arguments: email);
          } else {
            dialogs.showErrorDialog(
              context,
              'Failed to send OTP. Server error: ${redirectResponse.statusCode}',
            );
          }
        } else {
          dialogs.showErrorDialog(
            context,
            'Server configuration issue. Please try again later.',
          );
        }
      } else {
        dialogs.showErrorDialog(context, 'Failed to send OTP. Try again.');
      }
    } catch (e) {
      dialogs.showErrorDialog(context, e.toString());
    }
  }

  void redirectToRegister(BuildContext context) {
    Navigator.pushNamed(context, AppRouter.register);
  }
}
