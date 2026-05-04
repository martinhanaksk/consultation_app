// app_svg.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Centralises SVG asset loading

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgBuilder {
  // Loads an SVG from assets/resources/<name>.svg and tints it with [color].
  // If only [width] is provided, height matches width to keep the icon square.
  Widget icon(
    String name,
    Color color, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return SizedBox(
      width: width,
      height: height ?? width,
      child: SvgPicture.asset(
        'assets/resources/$name.svg',
        width: width,
        height: height ?? width,
        fit: fit,
        // BlendMode.srcIn replaces the SVG's own colours with [color]
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }
}
