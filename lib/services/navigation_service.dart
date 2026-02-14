import 'package:consultation_app/routes/app_router.dart';
import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  NavigatorState? _navigator() {
    return navigatorKey.currentState;
  }

  BuildContext? _context() {
    return _navigator()?.context;
  }

  //Auth
  void toLogin() {
    _navigator()?.pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
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
    _navigator()?.pushNamed(
      AppRouter.consultationsTeacherPage,
      arguments: <String, dynamic>{'token': token, 'email': email},
    );
  }

  void toStudentConsultations({required String token, required String email}) {
    _navigator()?.pushNamed(
      AppRouter.consultationsStudentPage,
      arguments: <String, dynamic>{'token': token, 'email': email},
    );
  }

  void toJoinRoom({required String token}) {
    _navigator()?.pushNamed(
      AppRouter.joinRoom,
      arguments: <String, dynamic>{'token': token},
    );
  }

  void toChangeSettings() {
    _navigator()?.pushNamed(AppRouter.changeSettings);
  }

  void toSupport() {
    _navigator()?.pushNamed(AppRouter.support);
  }

  void toProvideFeedback() {
    _navigator()?.pushNamed(AppRouter.provideFeedback);
  }

  void toCreateRoom() {
    _navigator()?.pushNamed(AppRouter.createRoom);
  }
}
