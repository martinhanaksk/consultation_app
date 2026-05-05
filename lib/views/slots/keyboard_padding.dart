import 'package:flutter/material.dart';

class KeyboardPadding extends StatelessWidget {
  final Widget child;
  const KeyboardPadding({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: child,
    );
  }
}
