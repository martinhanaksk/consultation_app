import 'package:consultation_app/viewmodels/create_room_viewmodel.dart';
import 'package:consultation_app/views/consultations_base_page.dart';
import 'package:consultation_app/views/consultations_owner_page.dart';
import 'package:consultation_app/views/create_block_page.dart';
import 'package:consultation_app/views/create_room_page.dart';
import 'package:consultation_app/views/add_slot_page.dart';
import 'package:consultation_app/views/display_list_of_emails_page.dart';
import 'package:consultation_app/views/display_slot_history_page.dart';
import 'package:consultation_app/views/display_users_in_room_page.dart';
import 'package:consultation_app/views/edit_block_page.dart';
import 'package:consultation_app/views/edit_room_page.dart';
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
  static const String addSlot = '/addSlot';
  static const String editBlock = '/editBlock';
  static const String editRoom = '/editRoom';
  static const String provideFeedback = '/provideFeedback';
  static const String changeSettings = '/changeSettings';
  static const String consultationsBasePage = '/consultationsBasePage';
  static const String consultationsOwnerPage = '/consultationsOwnerPage';
  static const String displayListOfEmails = '/displayListOfEmails';
  static const String displayUsersInRoom = '/displayUsersInRoom';
  static const String displaySlotHistory = '/displaySlotHistory';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case register:
        final args = settings.arguments as Map<String, dynamic>;
        final email = args['email'] as String;
        final rememberMe = args['rememberMe'] as bool;
        return MaterialPageRoute(
          builder: (_) =>
              RegistrationPage(email: email, rememberMe: rememberMe),
        );
      case login:
        return MaterialPageRoute(builder: (_) => const EmailInputPage());
      case consultationsBasePage:
        final args = settings.arguments as Map<String, dynamic>;
        final token = args['token'] as String;
        final email = args['email'] as String;
        return MaterialPageRoute(
          builder: (_) => BaseConsultationsPage(token: token, email: email),
        );
      case consultationsOwnerPage:
        final args = settings.arguments as Map<String, dynamic>;
        final token = args['token'] as String;
        final email = args['email'] as String;
        return MaterialPageRoute(
          builder: (_) => ConsultationsOwnerPage(token: token, email: email),
        );
      case verifyOtp:
        final args = settings.arguments as Map<String, dynamic>;
        final email = args['email'] as String;
        final rememberMe = args['rememberMe'] as bool;
        return MaterialPageRoute(
          builder: (_) => VerifyOtpPage(email: email, rememberMe: rememberMe),
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
        final onSuccess = args['onSuccess'] as VoidCallback?;
        return MaterialPageRoute(
          builder: (_) =>
              CreateBlock(token: token, roomId: roomId, onSuccess: onSuccess),
        );
      case addSlot:
        final args = settings.arguments as Map<String, dynamic>;
        final token = args['token'] as String;
        final blockId = args['blockId'] as String;
        final onSuccess = args['onSuccess'] as VoidCallback?;
        return MaterialPageRoute(
          builder: (_) =>
              AddSlot(token: token, blockId: blockId, onSuccess: onSuccess),
        );
      case editBlock:
        final args = settings.arguments as Map<String, dynamic>;
        final token = args['token'] as String;
        final roomId = args['roomId'] as String;
        final blockId = args['blockId'] as String;
        final onSuccess = args['onSuccess'] as VoidCallback?;
        return MaterialPageRoute(
          builder: (_) => EditBlock(
            token: token,
            roomId: roomId,
            blockId: blockId,
            onSuccess: onSuccess,
          ),
        );
        case editRoom:
        final args = settings.arguments as Map<String, dynamic>;
        final token = args['token'] as String;
        final roomId = args['roomId'] as int;
        return MaterialPageRoute(
          builder: (_) => EditRoomPage(
            token: token,
            roomId: roomId
          ),
        );
      case displayListOfEmails:
        final args = settings.arguments as Map<String, dynamic>;
        final viewModel = args['viewModel'] as CreateRoomViewmodel;
        return MaterialPageRoute(
          builder: (_) => DisplayListOfEmailsPage(viewModel: viewModel),
        );
      case displayUsersInRoom:
        final args = settings.arguments as Map<String, dynamic>;
        final roomId = args['roomId'] as int;
        final token = args['token'] as String;
        final roomName = args['roomName'] as String;
        return MaterialPageRoute(
          builder: (_) => DisplayUsersInRoomPage(
            token: token,
            roomId: roomId,
            roomName: roomName,
          ),
        );
      case displaySlotHistory:
        final args = settings.arguments as Map<String, dynamic>;
        final history = args['history'] as String;
        return MaterialPageRoute(
          builder: (_) => DisplaySlotHistoryPage(history: history),
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
