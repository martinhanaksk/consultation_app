import 'package:consultation_app/views/consultations_user_page.dart';
import 'package:consultation_app/views/login_page.dart';
import 'package:consultation_app/views/verify_otp_page.dart';
import 'package:consultation_app/views/welcome_page.dart';
import 'package:consultation_app/views/registration_page.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String verifyOtp = '/verifyOtp';
  static const String register = '/register';
  static const String detail = '/detail';
  static const String cousultationsUserPage = '/cousultationsUserPage';
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        final token = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => WelcomePage(token: token));
      case register:
        return MaterialPageRoute(builder: (_) => const RegistrationPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case cousultationsUserPage:
        return MaterialPageRoute(builder: (_) => const ConsultationsUserPage());
      case verifyOtp:
        final email = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => VerifyOtpPage(email: email));
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}
