import 'package:consultation_app/routes/app_router.dart';
import 'package:consultation_app/viewmodels/create_room_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  NavigatorState? _navigator() {
    return navigatorKey.currentState;
  }

  BuildContext? _context() {
    return _navigator()?.context;
  }

  //Auth
  void toLogin() async {
    _navigator()?.popUntil((route) => route.isFirst);
    _navigator()?.pushReplacementNamed(AppRouter.login);
  }

Future<dynamic> toVerifyOtp({
  required String email,
  bool rememberMe = false,
}) {
  return _navigator()!.pushNamed(
    AppRouter.verifyOtp,
    arguments: {'email': email, 'rememberMe': rememberMe},
  );
}

  void redirectToRegister(BuildContext context, String email) {
    Navigator.pushNamed(
      context,
      AppRouter.register,
      arguments: <String, dynamic>{'email': email},
    );
  }

  void toRegister({required String email,required bool rememberMe}) {
    _navigator()?.pushNamed(
      AppRouter.register,
      arguments: <String, dynamic>{'email': email,'rememberMe': rememberMe},
    );
  }

  //App

  void toOwnerConsultations({required String token, required String email}) {
    _navigator()?.pushNamedAndRemoveUntil(
      AppRouter.consultationsOwnerPage,
      (route) => false,
      arguments: <String, dynamic>{'token': token, 'email': email},
    );
  }

  void toBaseConsultations({required String token, required String email}) {
    _navigator()?.pushNamedAndRemoveUntil(
      AppRouter.consultationsBasePage,
      (route) => false,
      arguments: <String, dynamic>{'token': token, 'email': email},
    );
  }

  void toJoinRoom({required String token}) {
    _navigator()?.pushNamed(
      AppRouter.joinRoom,
      arguments: <String, dynamic>{'token': token},
    );
  }

  void toCreateBlock({
    required String token,
    required String roomId,
    required VoidCallback? onSuccess,
  }) {
    _navigator()?.pushNamed(
      AppRouter.createBlock,
      arguments: <String, dynamic>{
        'token': token,
        'roomId': roomId,
        'onSuccess': onSuccess,
      },
    );
  }

  void toEditBlock({
    required String token,
    required String roomId,
    required String blockId,
    required VoidCallback? onSuccess,
  }) {
    _navigator()?.pushNamed(
      AppRouter.editBlock,
      arguments: <String, dynamic>{
        'token': token,
        'roomId': roomId,
        'blockId': blockId,
        'onSuccess': onSuccess,
      },
    );
  }

  void toDisplayUsersInRoom({
    required String token,
    required int roomId,
    required String roomName,
  }) {
    _navigator()?.pushNamed(
      AppRouter.displayUsersInRoom,
      arguments: <String, dynamic>{
        'token': token,
        'roomId': roomId,
        'roomName': roomName,
      },
    );
  }

  void toDisplayListOfEmails({required CreateRoomViewmodel viewModel}) {
    _navigator()?.pushNamed(
      AppRouter.displayListOfEmails,
      arguments: <String, dynamic>{'viewModel': viewModel},
    );
  }

  void toChangeSettings() {
    _navigator()?.pushNamed(AppRouter.changeSettings);
  }

  void toProvideFeedback() {
    _navigator()?.pushNamed(AppRouter.provideFeedback);
  }

  void toCreateRoom() {
    _navigator()?.pushNamed(AppRouter.createRoom);
  }

  void pop() {
    _navigator()?.pop();
  }
}
