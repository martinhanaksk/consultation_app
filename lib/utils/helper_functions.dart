import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:consultation_app/setup.dart';
import 'package:http/http.dart' as http;

class HelperFunctions {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  Future<bool> handleIsInternetConnection() async {
    final List<ConnectivityResult> connectivityResult = await Connectivity()
        .checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    }

    return true;
  }

  

  String acceptedEmailsFormater(List<String> acceptedEmailsArray) {
    if (acceptedEmailsArray.isEmpty) return '';
    return acceptedEmailsArray.join(',');
  }

  String dateTimeToString(DateTime dateTime) {
    return dateTime.toIso8601String().split('.').first;
  }

  int compareTimeStringsDesc(String t1, String t2) {
    Duration toDuration(String t) {
      final parts = t.split(':');
      return Duration(
        hours: parts.isNotEmpty ? (int.tryParse(parts[0]) ?? 0) : 0,
        minutes: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
        seconds: parts.length > 2 ? (int.tryParse(parts[2]) ?? 0) : 0,
      );
    }

    final d1 = toDuration(t1);
    final d2 = toDuration(t2);
    return d2.compareTo(d1);
  }

  String getTimeOnlySimple(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  String getTDateOnlySimple(DateTime dateTime) {
    String weekday = DateFormat('EE').format(dateTime);
    String dayMonth = DateFormat('d.M').format(dateTime);
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
    return int.tryParse(s) != null;
  }

  Future<void> handleServer(
    http.Response response,
    String email,
    bool rememberMe,
  ) async {
    if (response.statusCode == 200) {
      await nav.toVerifyOtp(email: email, rememberMe: rememberMe);
    } else if (response.statusCode == 400) {
      redirectToRegister(email, rememberMe);
    } else {
      notify.showToast('Failed to send OTP, try again later');
    }
  }

  void redirectToRegister(String email, bool rememberMe) {
    nav.toRegister(email: email, rememberMe: rememberMe);
  }

  
}
