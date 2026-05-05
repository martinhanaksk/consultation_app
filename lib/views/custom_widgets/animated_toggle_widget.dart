// animated_toggle_widget.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// A two-option animated toggle switch. The active pill slides left/right
// over a static background row that always shows both labels.
// Used in owner room page to switch between the owner and student view.

import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class AnimatedToggle extends StatefulWidget {
  final bool isOwner;
  final List<String> values;
  final ValueChanged<int> onToggleCallback;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color buttonColor;
  final Color textColor;

  const AnimatedToggle({
    super.key,
    required this.values,
    required this.isOwner,
    required this.onToggleCallback,
    required this.width,
    required this.height,
    required this.backgroundColor,
    required this.buttonColor,
    required this.textColor,
  }) : assert(values.length == 2, 'AnimatedToggle needs exactly 2 values.');

  @override
  State<AnimatedToggle> createState() => _AnimatedToggleState();
}

class _AnimatedToggleState extends State<AnimatedToggle> {
  // true = left option (owner/values[0]); false = right option (student/values[1])
  bool initialPosition = true;

  @override
  void initState() {
    super.initState();
    initialPosition = widget.isOwner;
  }

  void _toggle() {
    setState(() {
      initialPosition = !initialPosition;
    });
    // Callback receives 1 for left (owner) and 0 for right (student)
    widget.onToggleCallback(initialPosition ? 1 : 0);
  }

  @override
  Widget build(BuildContext context) {
    final selectedText =
        initialPosition ? widget.values[0] : widget.values[1];

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          // Static background layer: both labels always visible, full-width tap area
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggle,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: ShapeDecoration(
                color: widget.backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(widget.height / 2),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.values[0],
                        style: TextStyle(
                          fontSize: constants.fsLabel,
                          fontWeight: constants.fwSemiBold,
                          color: constants.darkGrey,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.values[1],
                        style: TextStyle(
                          fontSize: constants.fsLabel,
                          fontWeight: constants.fwSemiBold,
                          color: constants.darkGrey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Animated pill: slides over the background to indicate the active option.
          // Exactly half the total width so it covers one label at a time.
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.decelerate,
            alignment: initialPosition
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Container(
              width: widget.width / 2,
              height: widget.height,
              decoration: ShapeDecoration(
                color: widget.buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(widget.height / 2),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                selectedText,
                style: TextStyle(
                  fontSize: constants.fsLabel,
                  color: widget.textColor,
                  fontWeight: constants.fwSemiBold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
