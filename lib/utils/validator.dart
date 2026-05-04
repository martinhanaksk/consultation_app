// validator.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Form field validators that show a toast on failure and return false.

import 'package:consultation_app/setup.dart';
import 'package:flutter/material.dart';

class Validator {
  // Returns false silently — the caller is responsible for showing feedback
  bool validateNotEmpty(String? value, BuildContext context) {
    if (value == null || value.trim().isEmpty) {
      return false;
    }
    return true;
  }

  // Shows a toast before returning false
  bool validateEmail(String? value, BuildContext context) {
    if (value == null || value.trim().isEmpty) {
      notify.showToast("Email is required");
      return false;
    }
    // Requires exactly one @ with non-empty parts on both sides
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value.trim())) {
      notify.showToast('Enter a valid email address');
      return false;
    }
    return true;
  }
}
