import 'package:intl/intl.dart';

class HelperFunctions {
  String dateTimeToString(DateTime dateTime) {
    return dateTime.toIso8601String().split('.').first;
  }

  String getTimeOnlySimple(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  String getTDateOnlySimple(DateTime dateTime) {
    String weekday = DateFormat('EEEE').format(dateTime); // Thursday
    String dayMonth = DateFormat('d.M').format(dateTime); // 4.1
    return "$weekday $dayMonth";
  }
}
