import 'package:consultation_app/setup.dart';
import 'package:consultation_app/utils/notify_user_utils.dart';
import 'package:flutter/material.dart';

class Validator {
  bool validateNotEmpty(String? value, BuildContext context) {
    if (value == null || value.trim().isEmpty) {
      
      return false;
    }
    return true;
  }

  bool validateEmail(String? value, BuildContext context) {
    if (value == null || value.trim().isEmpty) {
      notify.showToast("Email is required");
      return false;
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value.trim())) {
      notify.showToast('Enter a valid email address');
      return false;
    }
    return true;
  }
}
