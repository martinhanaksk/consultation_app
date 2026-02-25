import 'package:flutter/material.dart';

class Constants {
  Color white = Color(0xFFFFFFFF);
  Color darkWhite = Color(0xFFF2F3F8);
  Color lightGrey = Color(0xFFD9D9D9);
  Color grey = Color(0xFF787878);
  Color darkGrey = Color(0xFF3D3D3D);
  Color green = Color(0xFF10A64A);
  Color red = Color(0xFFFF0000);
  Color lightRed = Color(0xFFFF5D5D);
  Color primary = Color(0xFF0071E2);

  double fontSizeBig = 40;
  double fontSizeMedium = 30;
  double fontSizeSmall = 20;
  double fontSizeVerySmall = 13;
  double oneItemHeight = 80;
  bool testing = false;
  String url = '';
  static final Constants _instance = Constants._internal();
  factory Constants() => _instance;
  Constants._internal();
  void checkIfTestingServer(isTesting) {
    if (isTesting) {
      testing = true;
      url = "https://consultations-backend.onrender.com";
    } else {
      testing = false;
      url = "https://office-hours.fit.vutbr.cz/dev";
    }
  }
  //school server:

  //testing url:
}
