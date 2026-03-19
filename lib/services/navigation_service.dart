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

  void toVerifyOtp({
    required String email,
    required String token,
    bool rememberMe = false,
  }) {
    _navigator()?.pushNamed(
      AppRouter.verifyOtp,
      arguments: {'email': email, 'token': token, 'rememberMe': rememberMe},
    );
  }

  void redirectToRegister(BuildContext context, String email) {
    Navigator.pushNamed(
      context,
      AppRouter.register,
      arguments: <String, dynamic>{'email': email},
    );
  }

  void toRegister({required String email}) {
    _navigator()?.pushNamed(
      AppRouter.register,
      arguments: <String, dynamic>{'email': email},
    );
  }

  //App

  void toTeacherConsultations({required String token, required String email}) {
    _navigator()?.pushNamedAndRemoveUntil(
      AppRouter.consultationsTeacherPage,
      (route) => false,
      arguments: <String, dynamic>{'token': token, 'email': email},
    );
  }

  void toStudentConsultations({required String token, required String email}) {
    _navigator()?.pushNamedAndRemoveUntil(
      AppRouter.consultationsStudentPage,
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
void toDisplayListOfEmails({required CreateRoomViewmodel viewModel}) {
    _navigator()?.pushNamed(AppRouter.displayListOfEmails, arguments: <String, dynamic>{'viewModel': viewModel},);
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
