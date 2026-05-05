// keyboard_padding_widget.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Wraps a widget with bottom padding equal to the on-screen keyboard height,
// preventing the keyboard from obscuring input fields inside bottom sheets or dialogs.

import 'package:flutter/material.dart';

class KeyboardPadding extends StatelessWidget {
  final Widget child;

  const KeyboardPadding({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // viewInsets.bottom reflects the current keyboard height; it is 0 when the keyboard is hidden
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: child,
    );
  }
}
