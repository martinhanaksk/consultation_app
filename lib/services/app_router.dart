// app_router.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Centralises all named routes and argument parsing for the app.
// Every navigation target is declared here

import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/base_room_viewmodel.dart';
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
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RegistrationPage(
            email: args['email'] as String,
            rememberMe: args['rememberMe'] as bool,
          ),
        );
      case login:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const EmailInputPage(),
        );
      case consultationsBasePage:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BaseConsultationsPage(),
        );
      case consultationsOwnerPage:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ConsultationsOwnerPage(),
        );
      case verifyOtp:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => VerifyOtpPage(
            email: args['email'] as String,
            rememberMe: args['rememberMe'] as bool,
          ),
        );
      case joinRoom:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => JoinRoomPage(),
        );
      case createRoom:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => CreateRoomPage(),
        );
      case createBlock:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => CreateBlockPage(
            roomId: args['roomId'] as int,
            onSuccess: args['onSuccess'] as VoidCallback?,
          ),
        );
      case addSlot:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => AddSlotPage(
            blockId: args['blockId'] as int,
            onSuccess: args['onSuccess'] as VoidCallback?,
          ),
        );
      case editBlock:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => EditBlockPage(
            roomId: args['roomId'] as int,
            blockId: args['blockId'] as int,
            onSuccess: args['onSuccess'] as VoidCallback?,
          ),
        );
      case editRoom:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => EditRoomPage(roomId: args['roomId'] as int),
        );
      case displayListOfEmails: // Typed as dynamic to avoid a hard dependency on the concrete viewmodel type
        final args = settings.arguments as Map<String, BaseRoomViewModel>;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => DisplayListOfEmailsPage(viewModel: args['viewModel']!),
        );
      case displayNotifyHours:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => DisplayNotifyHoursPage(viewModel: args['viewModel']),
        );
      case displayUsersInRoom:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => DisplayUsersInRoomPage(
            roomId: args['roomId'] as int,
            roomName: args['roomName'] as String,
          ),
        );
      case displaySlotHistory:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) =>
              DisplaySlotHistoryPage(history: args['history'] as String),
        );
      case displayMyReservations:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MyReservationsPage(),
        );
      case changeSettings:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ChangeSettingsPage(),
        );
         // Fallback for any unregistered route — shown instead of a blank crash screen
      default:
        return MaterialPageRoute(
          settings: settings,
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
