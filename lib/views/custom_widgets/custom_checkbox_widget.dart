// custom_checkbox_widget.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// A thin wrapper around Flutter's Checkbox
// colours and shape, and scales the control 
//up by 20 % so it is easy to touch.

import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Transform.scale enlarges the hit area
    return Transform.scale(
      scale: 1.2,
      child: Checkbox(
        value: value,
        activeColor: constants.checkboxColor,
        checkColor: constants.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        onChanged: onChanged,
      ),
    );
  }
}
