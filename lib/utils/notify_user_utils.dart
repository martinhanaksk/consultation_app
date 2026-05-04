// notify_user_utils.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Wraps Fluttertoast to provide a single consistent toast style across the app.

import 'package:consultation_app/setup.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NotifyUserUtils {
  // Shows a bottom toast styled with app colours.
  void showToast(String text, {String title = "", bool isError = false}) {
    Fluttertoast.showToast(
      msg: title.isEmpty ? text : "$title\n$text",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? constants.red : constants.background,
      textColor: isError ? constants.white : constants.darkGrey,
      fontSize: constants.fsBody,
    );
  }
}
