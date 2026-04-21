import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';
import 'package:url_launcher/url_launcher.dart';

class SliderMenuViewmodel extends ChangeNotifier {
  String _token = "";
  String? _email = "";
  bool? _isOwner;
  bool _isLoading = false;
  final Uri _url = Uri.parse(
    'https://docs.google.com/forms/d/e/1FAIpQLScm7rfzCowdWgC_8-yCJURY5DqBcwrsp9zDaRoVqFF2O3Bc2Q/viewform?usp=publish-editor',
  );
  Future<void> launchFeedbackWebsite() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  void closeDrawer(BuildContext context) {
    if (Scaffold.maybeOf(context)?.isDrawerOpen == true) {
      Scaffold.of(context).closeDrawer();
    }
  }

  bool get isLoading => _isLoading;
  String get token => _token;
  bool? get isOwner => _isOwner;
  String? get email => _email;

  void checkSliderMenuFundamentals() async {
    if (_isLoading) {
      return;
    }
    try {
      _isLoading = true;
      notifyListeners();
      _token = await securePrefs.getToken();
      helpers.checkIfValidToken(_token);
      _email = await prefs.getItem('email');
      if (!await helpers.handleIsInternetConnection()) {
        notify.showToast('Please connect to internet.');
        _isOwner = false;
      } else {
        bool isOwnerTemp = await api.getIsOwner();
        notifyListeners();
        _isOwner = isOwnerTemp;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
