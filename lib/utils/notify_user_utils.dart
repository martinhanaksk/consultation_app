import 'package:consultation_app/setup.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NotifyUserUtils {
  void showToast(String text, {String title = ""}) {
    final msg = title.isEmpty ? text : "$title\n$text";
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      webPosition: "center",
      backgroundColor: constants.background,
      textColor: constants.darkGrey,
      fontSize: constants.fsBody,
    );
  }
}
