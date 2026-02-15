import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class SliderMenuViewmodel extends ChangeNotifier {
  bool _isOpen = false;
  String _token = "";
  String? _email = "";
  bool? _isTeacher;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  String get token => _token;
  bool? get isTeacher => _isTeacher;
  bool? get isOpen => _isOpen;
  String? get email => _email;

  void checkIfInSharedPreferences() async {
    if (_isLoading) {
      return;
    }
    try {
      _isLoading = true;
      notifyListeners();
      _token = await prefs.getItem('token');
      helpers.checkIfValidToken(_token);
      _email = await prefs.getItem('email');
      if (!await helpers.handleIsInternetConnection()) {
        notify.showToast('Please connect to internet.');
      } else {
        bool isTeacherTemp = await getIsTeacher();
        _isTeacher = isTeacherTemp;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> getIsTeacher() async {
    String? role = await prefs.getItem('role');
    notifyListeners();
    if (role == 'teacher') {
      return true;
    }
    return false;
  }
}
