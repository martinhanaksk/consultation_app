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

  static final _radius = SmoothBorderRadius(
    cornerRadius: 12,
    cornerSmoothing: 0.6,
  );

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_handleTextChanged);
  }

  @override
  void didUpdateWidget(covariant CustomInputTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
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
    widget.onChanged?.call('');
    widget.onClear?.call();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final effectiveKeyboardType = widget.isUrl
        ? TextInputType.url
        : widget.keyboardType;

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
                            FilteringTextInputFormatter.allow(
                              RegExp(r"[a-zA-ZÀ-ž0-9 '-]"),
                            ),
                          ])));

    final hasText = _controller?.text.isNotEmpty ?? false;

    Widget? suffix;
    if (widget.showClearIcon && !widget.readOnly && hasText && _controller != null) {
      suffix = IconButton(
        onPressed: _clearText,
        icon: svgs.icon("cross", constants.darkGrey),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        splashRadius: 16,
        constraints: const BoxConstraints(),
      );
    }

    return Container(
      decoration: constants.squircleShadow(
        color: widget.backgroundColor ?? constants.background,
        borderRadius: _radius,
      ),
      child: ClipSmoothRect(
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
          scrollPadding: const EdgeInsets.only(bottom: 1000),
          style: TextStyle(color: widget.textColor ?? constants.darkGrey),
          decoration: InputDecoration(
            hintText: widget.hintText ?? "",
            filled: true,
            fillColor: widget.backgroundColor ?? constants.background,
            counterText: widget.textCounterEnabled ? null : "",
            suffixIcon: suffix,
            prefixIcon: widget.prefixIcon,
            suffixText: widget.suffixText,
            suffixStyle: widget.suffixStyle,
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
