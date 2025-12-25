import 'package:consultation_app/utils/constants.dart';
import 'package:flutter/material.dart';

class ChangeSettings extends StatelessWidget {
  ChangeSettings({super.key});
  final Constants _constants = Constants();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _constants.bgLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(child: Text("Change Settings")),
        ),
      ),
    );
  }
}
