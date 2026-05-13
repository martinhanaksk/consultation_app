// navigation_service.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Provides programmatic navigation without requiring a BuildContext.
// Tracks route history to check the current and previous route at any time.

import 'package:consultation_app/services/app_router.dart';
import 'package:consultation_app/viewmodels/base_room_viewmodel.dart';
import 'package:consultation_app/views/email_input_page.dart';
import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class NavigationService {
  // Required by MaterialApp.navigatorKey to drive navigation from outside the widget tree
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  // --- Core helpers ---

  NavigatorState? _navigator() {
    return navigatorKey.currentState;
  }

  // All named pushes go through here so _routeHistory stays in sync
  Future<dynamic> _pushNamed(String routeName, {Object? arguments}) {
    return _navigator()!.pushNamed(routeName, arguments: arguments);
  }

  void pop([dynamic value]) {
    _navigator()?.pop(value);
  }

  // --- Auth ---

  // Shows a spinner instantly while the session clears, then fades in the
  // login page and removes the entire back stack so the user cannot go back
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

  void redirectToRegister(String email) {
    _pushNamed(
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

  // --- Home pages ---

  // Resets the stack to a single root before replacing, preventing accumulating
  void toOwnerConsultations() {
    _navigator()?.popUntil((route) => route.isFirst);
    _pushNamed(AppRouter.consultationsOwnerPage);
  }

  void toBaseConsultations() {
    _navigator()?.popUntil((route) => route.isFirst);
    _pushNamed(AppRouter.consultationsBasePage);
  }

  // --- Rooms ---

  void toJoinRoomPage() {
    _pushNamed(AppRouter.joinRoom, arguments: <String, dynamic>{});
  }

  void toCreateRoomPage() => _pushNamed(AppRouter.createRoom);

  Future<dynamic> toEditRoom({required int roomId}) {
    return _pushNamed(AppRouter.editRoom, arguments: {'roomId': roomId});
  }

  void toDisplayUsersInRoom({required int roomId, required String roomName}) {
    _pushNamed(
      AppRouter.displayUsersInRoom,
      arguments: <String, dynamic>{'roomId': roomId, 'roomName': roomName},
    );
  }

  void toDisplayListOfEmails({required BaseRoomViewModel viewModel}) {
    _pushNamed(
      AppRouter.displayListOfEmails,
      arguments: <String, BaseRoomViewModel>{'viewModel': viewModel},
    );
  }

  void toMyReservations() {
    _pushNamed(AppRouter.displayMyReservations);
  }

  void toDisplayNotifyHours({required dynamic viewModel}) {
    _pushNamed(
      AppRouter.displayNotifyHours,
      arguments: <String, dynamic>{'viewModel': viewModel},
    );
  }

  // --- Blocks and slots ---

  void toCreateBlockPage({
    required int roomId,
    required VoidCallback? onSuccess,
  }) {
    _pushNamed(
      AppRouter.createBlock,
      arguments: <String, dynamic>{'roomId': roomId, 'onSuccess': onSuccess},
    );
  }

  void toEditBlockPage({
    required int roomId,
    required int blockId,
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

  void toAddSlotPage({required int blockId, required VoidCallback? onSuccess}) {
    _pushNamed(
      AppRouter.addSlot,
      arguments: <String, dynamic>{'blockId': blockId, 'onSuccess': onSuccess},
    );
  }

  void toDisplaySlotHistory({required String history}) {
    _pushNamed(
      AppRouter.displaySlotHistory,
      arguments: <String, dynamic>{'history': history},
    );
  }

  // --- Other ---

  void toChangeSettingsPage() => _pushNamed(AppRouter.changeSettings);

  void toProvideFeedback() => _pushNamed(AppRouter.provideFeedback);
}

class NavigationObserver extends NavigatorObserver {
  final List<String> history;
  NavigationObserver(this.history);

  @override
  void didPop(Route route, Route? previousRoute) {
    if (route.settings.name != null && history.isNotEmpty) {
      history.removeLast();
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    final name = route.settings.name;
    if (name != null) history.add(name);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (history.isNotEmpty) history.removeLast();
    final name = newRoute?.settings.name;
    if (name != null) history.add(name);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    if (route.settings.name != null && history.isNotEmpty) {
      history.removeLast();
    }
  }
}
