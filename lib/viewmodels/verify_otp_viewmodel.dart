// verify_otp_viewmodel.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// ViewModel for the OTP verification screen. Submits the email + OTP pair,
// loads the session on success, and routes to the correct home screen based
// on the user's role.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class VerifyOtpViewModel extends ChangeNotifier {
  Timer? _loadingTimer;
  bool _isLoading = false;
  // Prevents notifyListeners() from firing after the widget tree is disposed
  bool _disposed = false;
  bool isLoading() {
    return _isLoading;
  }

  Future<void> connect(String email, String otp, bool rememberMe) async {
    // Prevent duplicate OTP submissions while a request is already in progress
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    _loadingTimer?.cancel();
    _loadingTimer = Timer(const Duration(seconds: 10), () {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
        notify.showToast('Request timed out', isError: true);
      }
    });
    try {
      final success = await api.connect(email, otp, rememberMe);
      _loadingTimer?.cancel();
      if (success) {
        // Reload session so role and token are available for the routing decision below
        await sm.load();
        if (sm.role == 'teacher') {
          nav.toOwnerConsultations();
        } else if (sm.role == 'student') {
          nav.toBaseConsultations();
        }
      } else {
        _isLoading = false;
        notifyListeners();
        notify.showToast('Please enter a valid code');
      }
    } catch (e) {
      _loadingTimer?.cancel();
      _isLoading = false;
      notifyListeners();
      notify.showToast(
        'Connection failed, please try again later',
        isError: true,
      );
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _loadingTimer?.cancel();
    super.dispose();
  }

  // Overridden to guard against async callbacks firing after dispose()
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }
}
