import 'package:flutter/material.dart';

class Constants {
  Color bgLight = Color(0xFFF2F3F8);
  Color defaultDarkGrey = Color.fromARGB(255, 61, 61, 61);
  Color defaultGreen = Color.fromARGB(255, 16, 166, 74);
  Color defaultRed = Color.fromARGB(255, 255, 0, 0);
  Color primaryColor = Color.fromARGB(255, 0, 113, 226);
  Color defaultLightGrey = Color.fromARGB(255, 217, 217, 217);
  Color defaultWhite = Color.fromARGB(255, 255, 255, 255);
  double fontSizeBig = 40;
  double fontSizeMedium = 30;
  double fontSizeSmall = 20;
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
