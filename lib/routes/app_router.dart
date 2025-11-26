import 'package:consultation_app/views/consultationsStudent_page.dart';
import 'package:consultation_app/views/emailInput_page.dart';
import 'package:consultation_app/views/verifyOtp_page.dart';
import 'package:consultation_app/views/welcome_page.dart';
import 'package:consultation_app/views/registration_page.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String verifyOtp = '/verifyOtp';
  static const String register = '/register';
  static const String detail = '/detail';
  static const String consultationsUserPage = '/consultationsUserPage';
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        final token = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => WelcomePage(token: token));
      case register:
        return MaterialPageRoute(builder: (_) => const RegistrationPage());
      case login:
        return MaterialPageRoute(builder: (_) => const EmailInputPage());
      case consultationsUserPage:
        final args = settings.arguments as ConsultationsUserPageArgs;
        return MaterialPageRoute(
          builder: (_) => ConsultationsUserPage(
            token: args.token,
            currentUserEmail: args.email,
          ),
        );
      case verifyOtp:
        final args = settings.arguments as VerifyOtpPageArgs;
        return MaterialPageRoute(
          builder: (_) =>
              VerifyOtpPage(email: args.email, testingToken: args.testingToken),
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}
