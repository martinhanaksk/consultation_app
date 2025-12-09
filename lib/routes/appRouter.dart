import 'package:consultation_app/views/consultationsStudent_page.dart';
import 'package:consultation_app/views/consultationsTeacher_page.dart';
import 'package:consultation_app/views/createRoom_widget.dart';
import 'package:consultation_app/views/emailInput_page.dart';
import 'package:consultation_app/views/provideFeedback_page.dart';
import 'package:consultation_app/views/joinRoom_page.dart';
import 'package:consultation_app/views/changeSettings_page.dart';
import 'package:consultation_app/views/support_page.dart';
import 'package:consultation_app/views/verifyOtp_page.dart';
import 'package:consultation_app/views/registration_page.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static const String login = '/login';
  static const String verifyOtp = '/verifyOtp';
  static const String register = '/register';
  static const String detail = '/detail';
  static const String joinRoom = '/joinroom';
  static const String createRoom = '/createRoom';
  static const String support = '/support';
  static const String provideFeedback = '/provideFeedback';
  static const String changeSettings = '/changeSettings';
  static const String consultationsStudentPage = '/consultationsUserPage';
  static const String consultationsTeacherPage = '/consultationsTeacherPage';
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case register:
        final args = settings.arguments as Map<String, dynamic>;
        final email = args['email'] as String;
        return MaterialPageRoute(
          builder: (_) => RegistrationPage(email: email),
        );
      case login:
        return MaterialPageRoute(builder: (_) => const EmailInputPage());
      case consultationsStudentPage:
        final args = settings.arguments as ConsultationsStudentPageArgs;
        return MaterialPageRoute(
          builder: (_) =>
              ConsultationsStudentPage(token: args.token, email: args.email),
        );
      case consultationsTeacherPage:
        final args = settings.arguments as ConsultationsTeacherPageArgs;
        return MaterialPageRoute(
          builder: (_) =>
              ConsultationsTeacherPage(token: args.token, email: args.email),
        );
      case verifyOtp:
        final args = settings.arguments as VerifyOtpPageArgs;
        return MaterialPageRoute(
          builder: (_) => VerifyOtpPage(
            email: args.email,
            token: args.testingToken,
            rememberMe: args.rememberMe,
          ),
        );
      case joinRoom:
        final args = settings.arguments as Map<String, dynamic>;
        final token = args['token'] as String;
        return MaterialPageRoute(builder: (_) => JoinRoom(token: token));
      case createRoom:
        final args = settings.arguments as Map<String, dynamic>;
        final token = args['token'] as String;
        return MaterialPageRoute(builder: (_) => CreateRoom(token: token));
      case support:
        return MaterialPageRoute(builder: (_) => Support());
      case provideFeedback:
        return MaterialPageRoute(builder: (_) => ProvideFeedback());
      case changeSettings:
        return MaterialPageRoute(builder: (_) => ChangeSettings());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}
