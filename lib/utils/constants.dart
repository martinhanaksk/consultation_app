import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';

class Constants {
  Color background = Color(0xfff9f9f9);
  Color grey = Color(0xffbcbcbc);
  Color darkGrey = Color(0xff191c1f);
  Color green = Color(0xff15803d);
  Color lightGreen = Color(0xffbbf7d0);
  Color orange = Color(0xffc2410c);
  Color lightOrange = Color(0xfffed7aa);
  Color red = Color(0xffb91c1c);
  Color lightRed = Color(0xfffecaca);
  Color primary = Color(0xFF0071E2);
  Color lightPrimary = Color(0xff8dc6ff);
  Color transparent = Colors.transparent;
  double fsHeadline = 28;
  double fsTitle = 24;
  double fsBody = 20;
  double fsLabel = 16;
  FontWeight fwRegular = FontWeight.w400;
  FontWeight fwSemiBold = FontWeight.w600;
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
        borderRadius:
            borderRadius ??
            SmoothBorderRadius(
              cornerRadius: 0,
              cornerSmoothing: cornerSmoothing,
            ),
        side: border is Border
            ? (border)
                  .top // fallback: use top side for uniform borders
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
