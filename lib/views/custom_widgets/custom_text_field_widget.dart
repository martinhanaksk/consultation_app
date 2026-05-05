// custom_input_text_field.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// A highly configurable single/multi-line text field with squircle styling,
// input formatters, optional clear button, and controller lifecycle management.

import 'package:consultation_app/setup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:figma_squircle/figma_squircle.dart';

class CustomInputTextField extends StatefulWidget {
  final TextEditingController? controller;
  final bool readOnly;
  final String? hintText;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType keyboardType;
  final int maxLength;
  final FocusNode? focusNode;
  final int maxLines;
  final Color? textColor;
  final Color? backgroundColor;
  final bool textCounterEnabled;
  final bool filled;
  final ValueChanged<String>? onChanged;
  final bool isEmail;
  final bool isUrl;
  final bool textCenter;
  final String? suffixText;
  final TextStyle? suffixStyle;
  final bool showClearIcon;
  final VoidCallback? onClear;
  final Widget? prefixIcon;
  const CustomInputTextField({
    super.key,
    this.controller,
    this.readOnly = false,
    this.hintText,
    this.focusNode,
    this.inputFormatters,
    this.keyboardType = TextInputType.text,
    this.maxLength = 50,
    this.maxLines = 1,
    this.textColor,
    this.backgroundColor,
    this.textCounterEnabled = false,
    this.onChanged,
    this.textCenter = false,
    this.isEmail = false,
    this.isUrl = false,
    this.filled = false,
    this.suffixText,
    this.suffixStyle,
    this.showClearIcon = true,
    this.onClear,
    this.prefixIcon,
  });
  @override
  State<CustomInputTextField> createState() => _CustomInputTextFieldState();
}

class _CustomInputTextFieldState extends State<CustomInputTextField> {
  TextEditingController? get _controller => widget.controller;

  // Shared squircle radius used for both the shadow container and the clip shape
  static final _radius = SmoothBorderRadius(
    cornerRadius: 12,
    cornerSmoothing: 0.6,
  );
  @override
  void initState() {
    super.initState();
    // Listen to controller changes so the clear button appears/disappears
    widget.controller?.addListener(_handleTextChanged);
  }

  @override
  void didUpdateWidget(covariant CustomInputTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-attach listener if the controller instance is swapped from outside
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleTextChanged);
      widget.controller?.addListener(_handleTextChanged);
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_handleTextChanged);
    super.dispose();
  }

  void _handleTextChanged() {
    setState(() {});
  }

  void _clearText() {
    _controller?.clear();
    // Notify parent of the empty value and fire the optional clear callback
    widget.onChanged?.call('');
    widget.onClear?.call();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // isUrl overrides whatever keyboardType was passed in
    final effectiveKeyboardType = widget.isUrl
        ? TextInputType.url
        : widget.keyboardType;

    // If no custom formatters are provided, pick the appropriate restrictive
    // formatter based on keyboard type or semantic flags (email / url / default text)
    final effectiveInputFormatters =
        widget.inputFormatters ??
        (effectiveKeyboardType == TextInputType.number
            ? [FilteringTextInputFormatter.digitsOnly]
            : (widget.isEmail
                  ? [
                      FilteringTextInputFormatter.allow(
                        RegExp(r"[a-zA-Z0-9@._\-+]"),
                      ),
                    ]
                  : (widget.isUrl
                        ? [
                            FilteringTextInputFormatter.allow(
                              RegExp(r"[a-zA-Z0-9:/?#[\]@!$&'()*+,;=._~%-]"),
                            ),
                          ]
                        : [
                            // Default: allow letters (including diacritics), digits, spaces, hyphens, apostrophes
                            FilteringTextInputFormatter.allow(
                              RegExp(r"[a-zA-ZÀ-ž0-9 '-]"),
                            ),
                          ])));
    final hasText = _controller?.text.isNotEmpty ?? false;

    // Only show the clear button when the field is editable and has content
    Widget? suffix;
    if (widget.showClearIcon &&
        !widget.readOnly &&
        hasText &&
        _controller != null) {
      suffix = IconButton(
        onPressed: _clearText,
        icon: svgs.icon("cross", constants.darkGrey),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        splashRadius: 16,
        constraints: const BoxConstraints(),
      );
    }
    return Container(
      // Outer container carries the squircle-shaped drop shadow
      decoration: constants.squircleShadow(
        color: widget.backgroundColor ?? constants.background,
        borderRadius: _radius,
      ),
      child: ClipSmoothRect(
        // Clips the TextField to the squircle shape
        radius: _radius,
        child: TextField(
          readOnly: widget.readOnly,
          focusNode: widget.focusNode,
          controller: widget.controller,
          onChanged: (value) {
            widget.onChanged?.call(value);
            setState(() {});
          },
          keyboardType: effectiveKeyboardType,
          inputFormatters: effectiveInputFormatters,
          maxLength: widget.maxLength,
          maxLines: widget.maxLines,
          textAlign: widget.textCenter ? TextAlign.center : TextAlign.left,
          // Large bottom padding prevents the keyboard from obscuring the focused field
          scrollPadding: const EdgeInsets.only(bottom: 1000),
          style: TextStyle(color: widget.textColor ?? constants.darkGrey),
          decoration: InputDecoration(
            hintText: widget.hintText ?? "",
            filled: true,
            fillColor: widget.backgroundColor ?? constants.background,
            // Passing null shows the default counter; empty string hides it entirely
            counterText: widget.textCounterEnabled ? null : "",
            suffixIcon: suffix,
            prefixIcon: widget.prefixIcon,
            suffixText: widget.suffixText,
            suffixStyle: widget.suffixStyle,
            // All border variants removed
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}
