import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';
class Constants {
  Color ghostWhite = Color(0xFFF9F9F9);
  Color background = Color(0xFFF7F7F7);
  Color grey = Color(0xFFE4E4E4);
  Color softGrey = Color(0xFFBCBCBC);
  Color greyNonActive = Color(0xFF949494);
  Color darkGrey = Color(0xFF191C1F);
  Color green = Color(0xFF4ADE80);
  Color strawberryRed = Color(0xFFDC2626);
  Color primary = Color(0xFF0071E2);
  Color transparent = Colors.transparent;
  double fontSizeBig = 40;
  double fontSizeMedium = 30;
  double fontSizeSmall = 20;
  double fontSizeVerySmall = 13;
  double oneItemHeight = 80;
  bool testing = false;
  String url = '';
  ShapeDecoration figmaLightShadowWith({
  Color? color,
  SmoothBorderRadius? borderRadius,
  BoxBorder? border,
  Gradient? gradient,
  double cornerSmoothing = 0.6,
}) {
  return ShapeDecoration(
    shadows: const [
      BoxShadow(
        color: Color(0xFFD9D9D9),
        offset: Offset(0, 0),
        blurRadius: 9,
        spreadRadius: 0,
      ),
    ],
    color: color,
    gradient: gradient,
    shape: SmoothRectangleBorder(
      borderRadius: borderRadius ??
          SmoothBorderRadius(
            cornerRadius: 0,
            cornerSmoothing: cornerSmoothing,
          ),
      side: border is Border
          ? (border).top // fallback: use top side for uniform borders
          : BorderSide.none,
    ),
  );
}

  static final Constants _instance = Constants._internal();
  factory Constants() => _instance;
  Constants._internal();
  void checkIfTestingServer(isTesting) {
    if (isTesting) {
      testing = true;
      url = "https://consultations-backend.onrender.com/api/";
    } else {
      testing = false;
      url = "https://office-hours.fit.vutbr.cz/api/dev";
    }
  }
  //school server:

  //testing url:
}
