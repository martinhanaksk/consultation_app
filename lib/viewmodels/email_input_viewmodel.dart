import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:consultation_app/setup.dart';

class EmailInputViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool _isChecked = false;
  String? _errorMessage;
  String _email = '';
  bool get isLoading => _isLoading;
  bool get isChecked => _isChecked;
  String? get errorMessage => _errorMessage;
  String get email => _email;

  Future<void> continueToVerify(
    BuildContext context,
    String email,
    bool rememberMe,
  ) async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    notifyListeners();
    notify.showToast("Checking email...");
    try {
      final response = await http.post(
        Uri.parse('${constants.url}/auth/request-login-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      if (constants.testing) {
        handleTestingServer(response, context, email, rememberMe);
      } else {
        handleServer(response, context, email, rememberMe);
      }
    } catch (e) {
      notify.showToast("Please, check your internet connection.");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void checkIfInSharedPreferences(BuildContext context) async {
    String? token = await prefs.getItem('token');
    String? email = await prefs.getItem('email');
    String? role = await prefs.getItem('role');
    if (role.isNotEmpty && token.isNotEmpty && email.isNotEmpty) {
      bool isExpired = JwtDecoder.isExpired(token);

      if (!isExpired) {
        if (role == 'teacher') {
          nav.toTeacherConsultations(token: token, email: email);
        } else if (role == 'student') {
          nav.toStudentConsultations(token: token, email: email);
        }
      } else {
        await prefs.removeItem('token');
        await prefs.removeItem('email');
        await prefs.removeItem('role');
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
      nav.toVerifyOtp(
        email: email,
        token: response.body,
        rememberMe: rememberMe,
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
      nav.toVerifyOtp(email: email, token: "", rememberMe: rememberMe);
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
          nav.toVerifyOtp(
            email: email,
            token: response.body,
            rememberMe: rememberMe,
          );
        } else {
          notify.showToast(
            'Failed to send OTP. Server error: ${redirectResponse.statusCode}',
          );
        }
      } else {
        notify.showToast('Server configuration issue. Please try again later.');
      }
    } else if (response.statusCode == 400) {
      redirectToRegister(context, email);
    } else {
      notify.showToast('Failed to send OTP. Try again.');
    }
  }

  void updateEmail(String value) {
    _email = value;
  }

  void toggleRememberMe(bool? value) {
    _isChecked = value ?? false;
    notifyListeners();
  }

  void redirectToRegister(BuildContext context, String email) {
    nav.toRegister(email: email);
  }
}
