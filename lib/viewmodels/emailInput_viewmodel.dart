import 'package:consultation_app/utils/constants.dart';
import 'package:consultation_app/utils/notifyUserUtils.dart';
import 'package:consultation_app/views/verifyOtp_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:consultation_app/routes/app_router.dart';

class EmailInputViewmodel {
  NotifyUserUtils dialogs = NotifyUserUtils();
  Constants _constants = Constants();

  Future<void> continueToVerify(BuildContext context, String email) async {
    dialogs.showToast("Sending OTP...");
    try {
      final response = await http.post(
        Uri.parse('${_constants.url}/auth/request-login-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      if (_constants.testing) {
        print("----->" + response.runtimeType.toString());
        handleTestingServer(response, context, email);
      } else {
        handleServer(response, context, email);
      }
    } catch (e) {
      dialogs.showToast("Please, check your internet connection.");
    }
  }

  void handleTestingServer(
    http.Response response,
    BuildContext context,
    String email,
  ) {
    if (response.statusCode == 200) {
      Navigator.pushNamed(
        context,
        AppRouter.verifyOtp,
        arguments: VerifyOtpPageArgs(email: email, testingToken: response.body),
      );
    } else if (response.statusCode == 400) {
      redirectToRegister(context);
    }
  }

  void handleServer(
    http.Response response,
    BuildContext context,
    String email,
  ) async {
    if (response.statusCode == 200) {
      //Navigator.pop(context);
      Navigator.pushNamed(
        context,
        AppRouter.verifyOtp,
        arguments: VerifyOtpPageArgs(email: email, testingToken: ''),
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
            arguments: VerifyOtpPageArgs(email: email, testingToken: ''),
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
      redirectToRegister(context);
    } else {
      dialogs.showToast('Failed to send OTP. Try again.');
    }
  }

  void redirectToRegister(BuildContext context) {
    Navigator.pushNamed(context, AppRouter.register);
  }
}
