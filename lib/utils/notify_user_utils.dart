import 'package:consultation_app/setup.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NotifyUserUtils {
  void showToast(String text) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      webPosition: "center",
      backgroundColor: constants.background,
      textColor: constants.darkGrey,
      fontSize: constants.fsBody,
    );
  }
}
