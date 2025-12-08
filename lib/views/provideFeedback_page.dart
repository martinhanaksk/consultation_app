import 'package:consultation_app/utils/constants.dart';
import 'package:flutter/material.dart';

class ProvideFeedback extends StatelessWidget {
  ProvideFeedback({super.key});
  final Constants _constants = Constants();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _constants.bgLight,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(child: Text("Provide Feedback")),
      ),
    );
  }
}
