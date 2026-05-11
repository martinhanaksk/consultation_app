// theme_selector.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Manages the app's light/dark theme by mutating the Constants colour tokens
// at runtime and notifying listeners so the widget tree rebuilds.

import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class ThemeSelector extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  // Reads the persisted preference from the session and applies it on startup
  Future<void> initialize() async {
    _isDark = sm.isDarkModeOn;
    _applyTheme();
    notifyListeners();
  }

  // Updates the preference, applies new colours
  Future<void> setDarkMode(bool value) async {
    _isDark = value;
    sm.updateIsDarkModeOn(value);
    _applyTheme();
    notifyListeners();
    final context = nav.navigatorKey.currentContext;
    if (context != null) {
      void rebuild(Element el) {
        el.markNeedsBuild();
        el.visitChildren(rebuild);
      }

      (context as Element).visitChildren(rebuild);
    }
  }

  // Overwrites all colour tokens in Constants to match the current mode
  void _applyTheme() {
    if (_isDark) {
      constants.background = const Color(0xff121212);
      constants.grey = const Color(0xff3a3a3a);
      constants.darkGrey = const Color(0xfff5f5f5);
      constants.darkGrey30 = const Color(0xfff5f5f5).withAlpha(30);
      constants.darkGrey100 = const Color(0xfff5f5f5).withAlpha(100);
      constants.darkGrey150 = const Color(0xfff5f5f5).withAlpha(150);
      constants.darkGrey200 = const Color(0xfff5f5f5).withAlpha(200);
      constants.textUnavailableGrey = const Color.fromARGB(255, 112, 88, 86);
      constants.red = const Color(0xfff87171);
      constants.red30 = const Color(0xffb71c1c).withAlpha(30);
      constants.primary = const Color(0xff7fb3ff);
      constants.lightPrimary = const Color(0xff2a4e7a);
    } else {
      constants.background = const Color(0xfff9f9f9);
      constants.grey = const Color(0xffd0d0d0);
      constants.darkGrey30 = const Color(0xff191c1f).withAlpha(30);
      constants.darkGrey100 = const Color(0xff191c1f).withAlpha(100);
      constants.darkGrey150 = const Color(0xff191c1f).withAlpha(150);
      constants.darkGrey200 = const Color(0xff191c1f).withAlpha(200);
      constants.darkGrey = const Color(0xff191c1f);
      constants.textUnavailableGrey = const Color(0xfffdc6c1);
      constants.red = const Color(0xffb71c1c);
      constants.red30 = const Color(0xffb71c1c).withAlpha(30);
      constants.primary = const Color(0xff1a56be);
      constants.lightPrimary = const Color(0xff8dc6ff);
    }
  }
}
