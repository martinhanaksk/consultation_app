import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NotifyUserUtils {
  void showToast(String text) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      webPosition: "center",
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }
}
