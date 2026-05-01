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
