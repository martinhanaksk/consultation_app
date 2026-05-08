// app_router.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Centralises all named routes and argument parsing for the app.
// Every navigation target is declared here

import 'package:consultation_app/setup.dart';
import 'package:consultation_app/views/base_consultations/base_consultations_page.dart';
import 'package:consultation_app/views/display_notify_hours_page.dart';
import 'package:consultation_app/views/my_reservations_page.dart';
import 'package:consultation_app/views/owner_consultations_page.dart';
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
import 'package:consultation_app/views/settings/change_settings_page.dart';
import 'package:consultation_app/views/verify_otp_page.dart';
import 'package:consultation_app/views/registration_page.dart';
import 'package:flutter/material.dart';

class AppRouter {
  // Named route constants
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
   static const String displayMyReservations = '/displayMyReservations';
  static const String displayNotifyHours = '/displayNotifyHours';
  static const String displayUsersInRoom = '/displayUsersInRoom';
  static const String displaySlotHistory = '/displaySlotHistory';

  // Route factory wired into MaterialApp.onGenerateRoute.
  // Arguments are passed as Map<String, dynamic> via Navigator
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
        return MaterialPageRoute(builder: (_) => BaseConsultationsPage());
      case consultationsOwnerPage:
        return MaterialPageRoute(builder: (_) => ConsultationsOwnerPage());
      case verifyOtp:
        final args = settings.arguments as Map<String, dynamic>;
        final email = args['email'] as String;
        final rememberMe = args['rememberMe'] as bool;
        return MaterialPageRoute(
          builder: (_) => VerifyOtpPage(email: email, rememberMe: rememberMe),
        );
      case joinRoom:
        return MaterialPageRoute(builder: (_) => JoinRoomPage());
      case createRoom:
        return MaterialPageRoute(builder: (_) => CreateRoomPage());
      case createBlock:
        final args = settings.arguments as Map<String, dynamic>;
        final roomId = args['roomId'] as int;
        final onSuccess = args['onSuccess'] as VoidCallback?;
        return MaterialPageRoute(
          builder: (_) => CreateBlockPage(roomId: roomId, onSuccess: onSuccess),
        );
      case addSlot:
        final args = settings.arguments as Map<String, dynamic>;
        final blockId = args['blockId'] as int;
        final onSuccess = args['onSuccess'] as VoidCallback?;
        return MaterialPageRoute(
          builder: (_) => AddSlotPage(blockId: blockId, onSuccess: onSuccess),
        );
      case editBlock:
        final args = settings.arguments as Map<String, dynamic>;
        final roomId = args['roomId'] as int;
        final blockId = args['blockId'] as int;
        final onSuccess = args['onSuccess'] as VoidCallback?;
        return MaterialPageRoute(
          builder: (_) => EditBlockPage(
            roomId: roomId,
            blockId: blockId,
            onSuccess: onSuccess,
          ),
        );
      case editRoom:
        final args = settings.arguments as Map<String, dynamic>;
        final roomId = args['roomId'] as int;
        return MaterialPageRoute(builder: (_) => EditRoomPage(roomId: roomId));
      case displayListOfEmails:
        final args = settings.arguments as Map<String, dynamic>;
        // Typed as dynamic to avoid a hard dependency on the concrete viewmodel type
        final viewModel = args['viewModel'] as dynamic;
        return MaterialPageRoute(
          builder: (_) => DisplayListOfEmailsPage(viewModel: viewModel),
        );
      case displayNotifyHours:
        final args = settings.arguments as Map<String, dynamic>;
        final viewModel = args['viewModel'] as dynamic;
        return MaterialPageRoute(
          builder: (_) => DisplayNotifyHoursPage(viewModel: viewModel),
        );
      case displayUsersInRoom:
        final args = settings.arguments as Map<String, dynamic>;
        final roomId = args['roomId'] as int;
        final roomName = args['roomName'] as String;
        return MaterialPageRoute(
          builder: (_) =>
              DisplayUsersInRoomPage(roomId: roomId, roomName: roomName),
        );
      case displaySlotHistory:
        final args = settings.arguments as Map<String, dynamic>;
        final history = args['history'] as String;
        return MaterialPageRoute(
          builder: (_) => DisplaySlotHistoryPage(history: history),
        );
         case displayMyReservations:
        return MaterialPageRoute(
          builder: (_) => MyReservationsPage(),
        );
      case changeSettings:
        return MaterialPageRoute(builder: (_) => ChangeSettingsPage());
      // Fallback for any unregistered route — shown instead of a blank crash screen
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            backgroundColor: constants.background,
            body: Center(
              child: Text(
                'Page not found',
                style: TextStyle(
                  color: constants.darkGrey,
                  fontSize: constants.fsTitle,
                ),
              ),
            ),
          ),
        );
    }
  }
}
