import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:consultation_app/setup.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;

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

      await securePrefs.removeToken();
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

  String acceptedEmailsFormater(List<String> acceptedEmailsArray) {
    if (acceptedEmailsArray.isEmpty) return '';
    return acceptedEmailsArray.join(',');
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
      notify.showToast('Failed to send OTP. Try again.');
    }
  }

  void redirectToRegister(String email, bool rememberMe) {
    nav.toRegister(email: email, rememberMe: rememberMe);
  }

  void checkIfInSharedPreferences() async {
   String? token = await securePrefs.getToken();
    String? email = await prefs.getItem('email');
    String? role = await prefs.getItem('role');
     if (role != null && role.isNotEmpty && 
        token != null && token.isNotEmpty && 
        email != null && email.isNotEmpty) {
      
      bool isExpired = JwtDecoder.isExpired(token);

      if (!isExpired) {
        if (role == 'teacher') {
          nav.toOwnerConsultations(token: token, email: email);
        } else if (role == 'student') {
          nav.toBaseConsultations(token: token, email: email);
        }
      } else {
        await securePrefs.removeToken();
        await prefs.removeItem('email');
        await prefs.removeItem('role');
      }
    }
  
  }
}
