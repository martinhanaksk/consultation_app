import 'package:consultation_app/utils/constants.dart';
import 'package:consultation_app/utils/notifyUserUtils.dart';
import 'package:consultation_app/views/verifyOtp_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:consultation_app/routes/appRouter.dart';

class EmailInputViewmodel {
  NotifyUserUtils dialogs = NotifyUserUtils();
  Constants _constants = Constants();

  Future<void> continueToVerify(
    BuildContext context,
    String email,
    bool rememberMe,
  ) async {
    dialogs.showToast("Checking email...");
    try {
      final response = await http.post(
        Uri.parse('${_constants.url}/auth/request-login-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      if (_constants.testing) {
        handleTestingServer(response, context, email, rememberMe);
      } else {
        handleServer(response, context, email, rememberMe);
      }
    } catch (e) {
      dialogs.showToast("Please, check your internet connection.");
    }
  }

  void handleTestingServer(
    http.Response response,
    BuildContext context,
    String email,
    bool rememberMe,
  ) {
    if (response.statusCode == 200) {
      Navigator.pushNamed(
        context,
        AppRouter.verifyOtp,
        arguments: VerifyOtpPageArgs(
          email: email,
          testingToken: response.body,
          rememberMe: rememberMe,
        ),
      );
    } else if (response.statusCode == 400) {
      redirectToRegister(context, email);
    }
  }

  void handleServer(
    http.Response response,
    BuildContext context,
    String email,
    bool rememberMe,
  ) async {
    if (response.statusCode == 200) {
      //Navigator.pop(context);
      Navigator.pushNamed(
        context,
        AppRouter.verifyOtp,
        arguments: VerifyOtpPageArgs(
          email: email,
          testingToken: '',
          rememberMe: rememberMe,
        ),
      );
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
          Navigator.pushNamed(
            context,
            AppRouter.verifyOtp,
            arguments: VerifyOtpPageArgs(
              email: email,
              testingToken: '',
              rememberMe: rememberMe,
            ),
          );
        } else {
          dialogs.showToast(
            'Failed to send OTP. Server error: ${redirectResponse.statusCode}',
          );
        }
      } else {
        dialogs.showToast(
          'Server configuration issue. Please try again later.',
        );
      }
    } else if (response.statusCode == 400) {
      redirectToRegister(context, email);
    } else {
      dialogs.showToast('Failed to send OTP. Try again.');
    }
  }

  void redirectToRegister(BuildContext context, String email) {
    Navigator.pushNamed(
      context,
      AppRouter.register,
      arguments: {'email': email},
    );
  }
}
