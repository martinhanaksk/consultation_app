import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class ThemeSelector extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  Future<void> initialize() async {
    _isDark = await prefs.getItem('darkMode') ?? false;
    _applyTheme();
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDark = value;
    await prefs.saveItem('darkMode', value);
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

  void _applyTheme() {
    if (_isDark) {
      constants.background = const Color(0xFF121212);
      constants.grey = const Color(0xFF3A3A3A);
      constants.darkGrey = const Color(0xFFF5F5F5);
      constants.darkGrey30 = const Color(0xFFF5F5F5).withAlpha(30);
      constants.darkGrey100 = const Color(0xFFF5F5F5).withAlpha(100);
      constants.darkGrey150 = const Color(0xFFF5F5F5).withAlpha(150);
      constants.darkGrey200 = const Color(0xFFF5F5F5).withAlpha(200);
      constants.textUnavailableGrey = const Color.fromARGB(255, 112, 88, 86);
      constants.green = const Color(0xFF4ADE80);
      constants.red = const Color(0xFFF87171);
      constants.red30 = const Color(0xffB71C1C).withAlpha(30);
      constants.primary = const Color(0xFF7FB3FF);
      constants.lightPrimary = const Color(0xFF2A4E7A);
    } else {
      constants.background = const Color(0xfff9f9f9);
      constants.grey = const Color(0xFFD0D0D0);
      constants.darkGrey30 = const Color(0xff191c1f).withAlpha(30);
      constants.darkGrey100 = const Color(0xff191c1f).withAlpha(100);
      constants.darkGrey150 = const Color(0xff191c1f).withAlpha(150);
      constants.darkGrey200 = const Color(0xff191c1f).withAlpha(200);
      constants.darkGrey = const Color(0xff191c1f);
      constants.textUnavailableGrey = const Color(0xFFfdc6c1);
      constants.green = const Color(0xff15803d);
      constants.red = const Color(0xffB71C1C);
      constants.red30 = const Color(0xffB71C1C).withAlpha(30);
      constants.primary = const Color(0xFF1A56BE);
      constants.lightPrimary = const Color(0xff8dc6ff);
    }
  }
}
