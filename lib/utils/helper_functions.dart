import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:consultation_app/setup.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class HelperFunctions {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _hasLoggedOut = false;
  bool _isLoggingOut = false;
  Future<bool> handleIsInternetConnection() async {
    final List<ConnectivityResult> connectivityResult = await Connectivity()
        .checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    }

    return true;
  }

  Future<void> checkIfValidToken(String token) async {
    if (_isLoggingOut) return;

    _isLoggingOut = true;
    if (token == "") {
      _hasLoggedOut = true;
      await prefs.removeItem('token');
      await prefs.removeItem('email');
      await prefs.removeItem('role');
      notify.showToast('You were logged out.');
      // Navigate to login and clear all previous routes
      nav.toLogin();
    }
    Future.delayed(Duration(seconds: 2), () {
      _isLoggingOut = false;
    });
  }

  void resetLogoutFlag() {
    _hasLoggedOut = false;
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
    String weekday = DateFormat('EE').format(dateTime); // Thu
    String dayMonth = DateFormat('d.M').format(dateTime); // 4.10
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

  void checkIfInSharedPreferences() async {
    String token = await prefs.getItem('token');
    String email = await prefs.getItem('email');
    String role = await prefs.getItem('role');
    if (role.isNotEmpty && token.isNotEmpty && email.isNotEmpty) {
      bool isExpired = JwtDecoder.isExpired(token);

      if (!isExpired) {
        if (role == 'teacher') {
          nav.toTeacherConsultations(token: token, email: email);
        } else if (role == 'student') {
          nav.toStudentConsultations(token: token, email: email);
        }
      } else {
        await prefs.removeItem('token');
        await prefs.removeItem('email');
        await prefs.removeItem('role');
      }
    }
  }
}
