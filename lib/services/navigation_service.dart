import 'package:consultation_app/services/app_router.dart';
import 'package:consultation_app/views/email_input_page.dart';
import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final List<String> _routeHistory = [];

  String? get previousRoute => _routeHistory.length >= 2
      ? _routeHistory[_routeHistory.length - 2]
      : null;

  String? get currentRoute =>
      _routeHistory.isNotEmpty ? _routeHistory.last : null;

  NavigatorState? _navigator() {
    return navigatorKey.currentState;
  }

  BuildContext? _context() {
    return _navigator()?.context;
  }

  Future<dynamic> _pushNamed(String routeName, {Object? arguments}) {
    _routeHistory.add(routeName);
    return _navigator()!.pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic> _pushReplacementNamed(String routeName, {Object? arguments}) {
    if (_routeHistory.isNotEmpty) _routeHistory.removeLast();
    _routeHistory.add(routeName);
    return _navigator()!.pushReplacementNamed(routeName, arguments: arguments);
  }

  Future<dynamic> _pushNamedAndRemoveUntil(
    String routeName, {
    Object? arguments,
  }) {
    _routeHistory.clear();
    _routeHistory.add(routeName);
    return _navigator()!.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

 void toLogin() async {
  _navigator()?.push(
    PageRouteBuilder(
      opaque: true,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (_, __, ___) => Scaffold(
        backgroundColor: constants.background,
        body: Center(
          child: SpinKitPouringHourGlass(
            color: constants.primary,
            size: constants.fsHeadline,
          ),
        ),
      ),
    ),
  );

  await sm.clear();
  _routeHistory.clear();
  await Future.delayed(const Duration(milliseconds: 400));

  _navigator()?.pushAndRemoveUntil(
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => const EmailInputPage(),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 400),
    ),
    (route) => false,
  );
}

  Future<dynamic> toVerifyOtp({
    required String email,
    bool rememberMe = false,
  }) {
    return _pushNamed(
      AppRouter.verifyOtp,
      arguments: {'email': email, 'rememberMe': rememberMe},
    );
  }

  Future<dynamic> toEditRoom({required int roomId}) {
    return _pushNamed(AppRouter.editRoom, arguments: {'roomId': roomId});
  }

  void redirectToRegister(BuildContext context, String email) {
    _routeHistory.add(AppRouter.register);
    Navigator.pushNamed(
      context,
      AppRouter.register,
      arguments: <String, dynamic>{'email': email},
    );
  }

  void toRegister({required String email, required bool rememberMe}) {
    _pushNamed(
      AppRouter.register,
      arguments: <String, dynamic>{'email': email, 'rememberMe': rememberMe},
    );
  }

  void toOwnerConsultations() {
    _routeHistory.clear();
    _routeHistory.add(AppRouter.consultationsOwnerPage);
    _navigator()?.popUntil((route) => route.isFirst);
    _navigator()?.pushReplacementNamed(AppRouter.consultationsOwnerPage);
  }

  void toBaseConsultations() {
    _routeHistory.clear();
    _routeHistory.add(AppRouter.consultationsBasePage);
    _navigator()?.popUntil((route) => route.isFirst);
    _navigator()?.pushReplacementNamed(AppRouter.consultationsBasePage);
  }

  void toJoinRoom() {
    _pushNamed(AppRouter.joinRoom, arguments: <String, dynamic>{});
  }

  void toDisplaySlotHistory({required String history}) {
    _pushNamed(
      AppRouter.displaySlotHistory,
      arguments: <String, dynamic>{'history': history},
    );
  }

  void toCreateBlock({
    required String roomId,
    required VoidCallback? onSuccess,
  }) {
    _pushNamed(
      AppRouter.createBlock,
      arguments: <String, dynamic>{'roomId': roomId, 'onSuccess': onSuccess},
    );
  }

  void toAddSlot({required String blockId, required VoidCallback? onSuccess}) {
    _pushNamed(
      AppRouter.addSlot,
      arguments: <String, dynamic>{'blockId': blockId, 'onSuccess': onSuccess},
    );
  }

  void toEditBlock({
    required String roomId,
    required String blockId,
    required VoidCallback? onSuccess,
  }) {
    _pushNamed(
      AppRouter.editBlock,
      arguments: <String, dynamic>{
        'roomId': roomId,
        'blockId': blockId,
        'onSuccess': onSuccess,
      },
    );
  }

  void toDisplayUsersInRoom({required int roomId, required String roomName}) {
    _pushNamed(
      AppRouter.displayUsersInRoom,
      arguments: <String, dynamic>{'roomId': roomId, 'roomName': roomName},
    );
  }

  void toDisplayListOfEmails({required dynamic viewModel}) {
    _pushNamed(
      AppRouter.displayListOfEmails,
      arguments: <String, dynamic>{'viewModel': viewModel},
    );
  }

  void toChangeSettings() => _pushNamed(AppRouter.changeSettings);

  void toProvideFeedback() => _pushNamed(AppRouter.provideFeedback);

  void toCreateRoom() => _pushNamed(AppRouter.createRoom);

  void pop<T extends Object?>([T? result]) {
    if (_routeHistory.isNotEmpty) _routeHistory.removeLast();
    _navigator()?.pop(result);
  }
}
