// slider_menu_viewmodel.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// ViewModel for the side drawer (slider menu). Resolves the current user's
// token, email, and owner status on open, and provides helpers for launching
// the feedback website and closing the drawer safely.

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
      throw Exception('Could not launch \$constants.feedbackUrl');
    }
  }

  // Uses maybeOf to avoid throwing if the context is no longer attached to a Scaffold
  void closeDrawer(BuildContext context) {
    if (Scaffold.maybeOf(context)?.isDrawerOpen == true) {
      Scaffold.of(context).closeDrawer();
    }
  }

  bool get isLoading => _isLoading;
  String get token => _token;
  bool? get isOwner => _isOwner;
  String? get email => _email;

  // Called each time the drawer opens to refresh session data and owner status.
  // Guard prevents re-entry if a previous call is still in progress.
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
        notify.showToast('Please connect to internet', isError: true);
        // Default to non-owner so owner-only menu items are hidden when offline
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
