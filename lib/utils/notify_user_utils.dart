import 'package:consultation_app/setup.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NotifyUserUtils {
  void showToast(String text) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      webPosition: "center",
      backgroundColor: constants.ghostWhite,
      textColor: constants.darkGrey,
      fontSize: 16.0,
    );
  }
}
