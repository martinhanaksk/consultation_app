// email_input_viewmodel.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// ViewModel for the Email Input (login) screen. Sends an OTP request for the
// entered email and guards against stuck loading states with a 5-second timeout.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class EmailInputViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool _isChecked = false;
  // Prevents notifyListeners() from firing after the widget tree is disposed
  bool _disposed = false;
  String? _errorMessage;
  // Cancels itself if a response arrives before the timeout fires
  Timer? _loadingTimer;

  bool get isLoading => _isLoading;
  bool get isChecked => _isChecked;
  String? get errorMessage => _errorMessage;

  final TextEditingController emailController = TextEditingController();
  String get email => emailController.text;

  Future<void> continueToVerify(BuildContext context) async {
    // Prevent duplicate submissions if the button is tapped while already loading
    if (_isLoading) return;

    final trimmedEmail = helpers.trimText(email);

    _isLoading = true;
    notifyListeners();

    // Start the timeout before the API call so already sent request doesn't block the UI forever
    startLoadingTimeout();

    try {
      final response = await api.requestLoginOtp(trimmedEmail);
      _loadingTimer?.cancel();
      if (response == null) {
        resetLoading();
        return;
      }
      // Delegates navigation and session handling based on the server response
      helpers.handleServer(response, trimmedEmail, _isChecked);
      resetLoading();
    } catch (e) {
      _loadingTimer?.cancel();
      notify.showToast("Please, check your internet connection", isError: true);
      resetLoading();
    }
  }

  void checkAutoLogin() {
    sm.checkIfInSharedPreferences();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void resetLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void toggleRememberMe(bool? value) {
    _isChecked = value ?? false;
    notifyListeners();
  }

  // Resets the loading state after 5 seconds if no response has been received,
  // preventing the UI from being permanently stuck in a loading state
  void startLoadingTimeout() {
    _loadingTimer?.cancel();
    _loadingTimer = Timer(const Duration(seconds: 5), () {
      resetLoading();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _loadingTimer?.cancel();
    emailController.dispose();
    super.dispose();
  }

  // Overridden to guard against async callbacks firing after dispose()
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }
}
