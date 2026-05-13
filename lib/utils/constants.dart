// constants.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Constants is a singleton — the same instance is returned on every construction.

import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';

class Constants {
  // --- URLs ---

  final Uri feedbackUrl = Uri.parse(
    'https://docs.google.com/forms/d/e/1FAIpQLScm7rfzCowdWgC_8-yCJURY5DqBcwrsp9zDaRoVqFF2O3Bc2Q/viewform?usp=publish-editor',
  );

  // Server url
  String url = 'https://office-hours.fit.vutbr.cz/api';

  // --- Colours ---

  Color white = Color(0xffffffff);
  Color checkboxColor = Color(0xff2a4e7a);
  Color background = Color(0xfff9f9f9);
  Color grey = Color(0xffd0d0d0);
  // darkGrey variants at different opacities
  Color darkGrey30 = Color(0xff191c1f).withAlpha(30);
  Color darkGrey100 = Color(0xff191c1f).withAlpha(100);
  Color darkGrey150 = Color(0xff191c1f).withAlpha(150);
  Color darkGrey200 = Color(0xff191c1f).withAlpha(200);
  Color darkGrey = Color(0xff191c1f);
  Color textUnavailableGrey = Color(0xfffdc6c1);
  Color red = Color(0xffb71c1c);
  Color red30 = Color(0xffb71c1c).withAlpha(30);
  Color primary = Color(0xff1a56be);
  Color lightPrimary = Color(0xff8dc6ff);
  Color transparent = Colors.transparent;

  // --- Typography ---

  double fsHeadline = 28;
  double fsTitle = 24;
  double fsBody = 20;
  double fsLabel = 16;
  FontWeight fwRegular = FontWeight.w400;
  FontWeight fwSemiBold = FontWeight.w600;

  // --- Decorations ---

  // Returns a squircle (Figma-style smooth-corner) card decoration with a subtle shadow.
  // cornerSmoothing controls how gradually the corner curves blend into the straight edge.
  ShapeDecoration squircleShadow({
    Color? color,
    SmoothBorderRadius? borderRadius,
    bool hasBorder = true,
    Gradient? gradient,
    double cornerSmoothing = 0.6,
  }) {
    return ShapeDecoration(
      shadows: [
        BoxShadow(
          color: darkGrey30,
          offset: const Offset(0, 4),
          blurRadius: 12,
          spreadRadius: 0,
        ),
      ],
      color: color,
      gradient: gradient,
      shape: SmoothRectangleBorder(
        borderRadius:
            borderRadius ??
            SmoothBorderRadius(
              cornerRadius: 16,
              cornerSmoothing: cornerSmoothing,
            ),
        side: hasBorder ? BorderSide(color: grey, width: 1) : BorderSide.none,
      ),
    );
  }

  // --- Singleton ---

  static final Constants _instance = Constants._internal();
  factory Constants() => _instance;
  Constants._internal();
}
