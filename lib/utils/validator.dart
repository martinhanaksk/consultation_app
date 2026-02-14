import 'package:consultation_app/utils/notify_user_utils.dart';
import 'package:flutter/material.dart';

class Validator {
  final NotifyUserUtils dialogs = NotifyUserUtils();
  bool validateNotEmpty(String? value, String fieldName, BuildContext context) {
    if (value == null || value.trim().isEmpty) {
      dialogs.showToast('$fieldName is required');
      return false;
    }
    return true;
  }

  bool validateEmail(String? value, BuildContext context) {
    if (value == null || value.trim().isEmpty) {
      dialogs.showToast("Email is required");
      return false;
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value.trim())) {
      dialogs.showToast('Enter a valid email address');
      return false;
    }
    return true;
  }
}
