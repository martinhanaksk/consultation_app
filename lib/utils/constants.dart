import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';

class Constants {
  Color background = Color(0xfff9f9f9);
  Color grey = Color(0xFFD0D0D0);
  Color darkGrey = Color(0xff191c1f);
  Color textUnavailableGrey = Color.fromARGB(255, 193, 151, 146);
  Color onyxBlack = Color(0xFF0a0a0a);
  Color green = Color(0xff15803d);
  Color red = Color(0xffB71C1C);
  Color primary = Color(0xFF1A56BE);
  Color lightPrimary = Color(0xff8dc6ff);
  Color transparent = Colors.transparent;
  double fsHeadline = 28;
  double fsTitle = 24;
  double fsBody = 20;
  double fsLabel = 16;
  FontWeight fwRegular = FontWeight.w400;
  FontWeight fwSemiBold = FontWeight.w600;
  double oneItemHeight = 80;
  String url = '';
  ShapeDecoration squircleShadow({
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
              cornerRadius: 16,
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
  void setServerUrl() {
    
      url = "https://office-hours.fit.vutbr.cz/api/dev";
    
  }
  //school server:

  //testing url:
}
