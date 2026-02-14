import 'package:consultation_app/services/user_preferences.dart';
import 'package:consultation_app/utils/constants.dart';
import 'package:consultation_app/utils/notify_user_utils.dart';
import 'package:consultation_app/views/consultations_student_page.dart';
import 'package:consultation_app/views/consultations_teacher_page.dart';
import 'package:consultation_app/views/verify_otp_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:consultation_app/routes/app_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class EmailInputViewModel extends ChangeNotifier {
  NotifyUserUtils _dialogs = NotifyUserUtils();
  Constants _constants = Constants();
  UserPreferences _userPreferences = UserPreferences();
  bool isLoading = false;
  bool isChecked = false;
  String? errorMessage;
  String email = '';

  Future<void> continueToVerify(
    BuildContext context,
    String email,
    bool rememberMe,
  ) async {
    isLoading = true;
    notifyListeners();
    _dialogs.showToast("Checking email...");
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
      _dialogs.showToast("Please, check your internet connection.");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void checkIfInSharedPreferences(BuildContext context) async {
    String? token = await _userPreferences.getItem('token');
    String? email = await _userPreferences.getItem('email');
    String? role = await _userPreferences.getItem('role');
    if (token != null &&
        email != null &&
        role != null &&
        role.isNotEmpty &&
        token.isNotEmpty &&
        email.isNotEmpty) {
      bool isExpired = JwtDecoder.isExpired(token);

      if (!isExpired) {
        if (role == 'teacher') {
          Navigator.pushNamed(
            context,
            AppRouter.consultationsTeacherPage,
            arguments: ConsultationsTeacherPageArgs(token: token, email: email),
          );
        } else if (role == 'student') {
          Navigator.pushNamed(
            context,
            AppRouter.consultationsStudentPage,
            arguments: ConsultationsStudentPageArgs(token: token, email: email),
          );
        }
      } else {
        await _userPreferences.removeItem('token');
        await _userPreferences.removeItem('email');
        await _userPreferences.removeItem('role');
      }
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
          _dialogs.showToast(
            'Failed to send OTP. Server error: ${redirectResponse.statusCode}',
          );
        }
      } else {
        _dialogs.showToast(
          'Server configuration issue. Please try again later.',
        );
      }
    } else if (response.statusCode == 400) {
      redirectToRegister(context, email);
    } else {
      _dialogs.showToast('Failed to send OTP. Try again.');
    }
  }

  void updateEmail(String value) {
    email = value;
  }

  void toggleRememberMe(bool? value) {
    isChecked = value ?? false;
    notifyListeners();
  }

  void redirectToRegister(BuildContext context, String email) {
    Navigator.pushNamed(
      context,
      AppRouter.register,
      arguments: {'email': email},
    );
  }
}
