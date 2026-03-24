import 'package:consultation_app/viewmodels/create_room_viewmodel.dart';
import 'package:consultation_app/views/consultations_student_page.dart';
import 'package:consultation_app/views/consultations_teacher_page.dart';
import 'package:consultation_app/views/create_block_page.dart';
import 'package:consultation_app/views/create_room_page.dart';
import 'package:consultation_app/views/display_list_of_emails_page.dart';
import 'package:consultation_app/views/email_input_page.dart';
import 'package:consultation_app/views/join_room_page.dart';
import 'package:consultation_app/views/change_settings_page.dart';
import 'package:consultation_app/views/verify_otp_page.dart';
import 'package:consultation_app/views/registration_page.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static const String login = '/login';
  static const String verifyOtp = '/verifyOtp';
  static const String register = '/register';
  static const String detail = '/detail';
  static const String joinRoom = '/joinroom';
  static const String createRoom = '/createRoom';
  static const String createBlock = '/createBlock';
  static const String provideFeedback = '/provideFeedback';
  static const String changeSettings = '/changeSettings';
  static const String consultationsStudentPage = '/consultationsUserPage';
  static const String consultationsTeacherPage = '/consultationsTeacherPage';
  static const String displayListOfEmails = '/displayListOfEmails';

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
        final args = settings.arguments as Map<String, dynamic>;
        final token = args['token'] as String;
        final email = args['email'] as String;
        return MaterialPageRoute(
          builder: (_) => ConsultationsStudentPage(token: token, email: email),
        );
      case consultationsTeacherPage:
        final args = settings.arguments as Map<String, dynamic>;
        final token = args['token'] as String;
        final email = args['email'] as String;
        return MaterialPageRoute(
          builder: (_) => ConsultationsTeacherPage(token: token, email: email),
        );
      case verifyOtp:
        final args = settings.arguments as Map<String, dynamic>;
        final email = args['email'] as String;
        final token = args['token'] as String;
        final rememberMe = args['rememberMe'] as bool;
        return MaterialPageRoute(
          builder: (_) =>
              VerifyOtpPage(email: email, token: token, rememberMe: rememberMe),
        );
      case joinRoom:
        final args = settings.arguments as Map<String, dynamic>;
        final token = args['token'] as String;
        return MaterialPageRoute(builder: (_) => JoinRoom(token: token));
      case createRoom:
        return MaterialPageRoute(builder: (_) => CreateRoom());
      case createBlock:
        final args = settings.arguments as Map<String, dynamic>;
        final token = args['token'] as String;
        final roomId = args['roomId'] as String;
        return MaterialPageRoute(builder: (_) => CreateBlock(token:token,roomId:roomId));
      case displayListOfEmails:
        final args = settings.arguments as Map<String, dynamic>;
        final viewModel = args['viewModel'] as CreateRoomViewmodel;
        return MaterialPageRoute(
          builder: (_) => DisplayListOfEmailsPage(viewModel: viewModel),
        );
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
