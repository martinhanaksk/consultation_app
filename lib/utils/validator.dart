import 'package:consultation_app/utils/dialogs.dart';
import 'package:flutter/material.dart';

class Validator {
  final Dialogs dialogs = Dialogs();
  bool validateNotEmpty(String? value, String fieldName, BuildContext context) {
    if (value == null || value.trim().isEmpty) {
      dialogs.showErrorDialog(context, '$fieldName is required');
      return false;
    }
    return true;
  }

  bool validateEmail(String? value, BuildContext context) {
    if (value == null || value.trim().isEmpty) {
      dialogs.showErrorDialog(context, "Email is required");
      return false;
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value.trim())) {
      dialogs.showErrorDialog(context, 'Enter a valid email address');
      return false;
    }
    return true;
  }
}
