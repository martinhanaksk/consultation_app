import 'dart:async';

import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class EmailInputViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool _isChecked = false;
  String? _errorMessage;
  Timer? _loadingTimer;
  bool get isLoading => _isLoading;
  bool get isChecked => _isChecked;
  String? get errorMessage => _errorMessage;
  final TextEditingController emailController = TextEditingController();
  String get email => emailController.text;
   Future<void> continueToVerify(BuildContext context) async {
    if (_isLoading) return;

    final trimmedEmail = helpers.trimText(email);

    _isLoading = true;
    notifyListeners();

    startLoadingTimeout();

    try {
      final response = await api.requestLoginOtp(trimmedEmail);
      helpers.handleServer(response, trimmedEmail, _isChecked);
    } catch (e) {
      notify.showToast("Please, check your internet connection",isError: true);
      resetLoading();
    }
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void resetLoading() {
    _isLoading = false;
    notifyListeners();
  }void toggleRememberMe(bool? value) {
    _isChecked = value ?? false;
    notifyListeners();
  }
  

  void startLoadingTimeout() {
    _loadingTimer?.cancel();
    _loadingTimer = Timer(const Duration(seconds: 5), () {
      resetLoading();
    });
  }

 

  @override
  void dispose() {
    _loadingTimer?.cancel();
    emailController.dispose();
    super.dispose();
  }
}
