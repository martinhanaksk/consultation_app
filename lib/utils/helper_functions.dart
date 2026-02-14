import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class HelperFunctions {
  Future<bool> handleIsInternetConnection() async {
    final List<ConnectivityResult> connectivityResult = await Connectivity()
        .checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    }

    return true;
  }

  String dateTimeToString(DateTime dateTime) {
    return dateTime.toIso8601String().split('.').first;
  }

  int compareTimeStringsDesc(String t1, String t2) {
    Duration toDuration(String t) {
      final parts = t.split(':');
      return Duration(
        hours: int.parse(parts[0]),
        minutes: int.parse(parts[1]),
        seconds: int.parse(parts[2]),
      );
    }

    final d1 = toDuration(t1);
    final d2 = toDuration(t2);
    //is t1>t2?
    print("AA");
    print(d2.compareTo(d1));
    return d2.compareTo(d1);
  }

  String getTimeOnlySimple(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  String getTDateOnlySimple(DateTime dateTime) {
    String weekday = DateFormat('EEEE').format(dateTime); // Thursday
    String dayMonth = DateFormat('d.M').format(dateTime); // 4.1
    return "$weekday $dayMonth";
  }

  String trimText(String text) {
    return text.trim();
  }

  String cropText(String text) {
    String trimmed = text.trim();
    int maxTextLength = 12;
    if (trimmed.length > maxTextLength) {
      return '${trimmed.substring(0, maxTextLength)}...';
    }

    return trimmed;
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return int.tryParse(s) != null;
  }
}
