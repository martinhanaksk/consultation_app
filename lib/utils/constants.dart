import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';

class Constants {
  Color white = Color(0xffffffff);
  Color checkboxColor = Color(0xFF2A4E7A);
  Color background = Color(0xfff9f9f9);
  Color grey = Color(0xFFD0D0D0);
  Color darkGrey30 = Color(0xff191c1f).withAlpha(30);
  Color darkGrey100 = Color(0xff191c1f).withAlpha(100);
  Color darkGrey150 = Color(0xff191c1f).withAlpha(150);
  Color darkGrey200 = Color(0xff191c1f).withAlpha(200);
  Color darkGrey = Color(0xff191c1f);
  Color textUnavailableGrey = Color(0xFFfdc6c1);
  Color green = Color(0xff15803d);
  Color red = Color(0xffB71C1C);
  Color red30 = Color(0xffB71C1C).withAlpha(30);
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

  static final Constants _instance = Constants._internal();
  factory Constants() => _instance;
  Constants._internal();
  void setServerUrl() {
    url = "https://office-hours.fit.vutbr.cz/api/dev";
  }
}
