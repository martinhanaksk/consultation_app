import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';
import 'package:url_launcher/url_launcher.dart';

class SliderMenuViewmodel extends ChangeNotifier {
  String _token = "";
  String? _email = "";
  bool? _isOwner;
  bool _isLoading = false;
  
  Future<void> launchFeedbackWebsite() async {
    if (!await launchUrl(constants.feedbackUrl)) {
      throw Exception('Could not launch $constants.feedbackUrl');
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
      _token = sm.token;
      sm.checkIfValidToken();
      _email = sm.email;
      if (!await helpers.handleIsInternetConnection()) {
        notify.showToast('Please connect to internet',isError: true);
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
