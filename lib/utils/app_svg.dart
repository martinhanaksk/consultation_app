import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgBuilder {
  Widget icon(
    String name, {
    double? width,
    double? height,
    Color? color,
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
        colorFilter: color != null
            ? ColorFilter.mode(color, BlendMode.srcIn)
            : null,
      ),
    );
  }
}
