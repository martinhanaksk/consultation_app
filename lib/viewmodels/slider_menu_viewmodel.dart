// slider_menu_viewmodel.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// ViewModel for the side drawer (slider menu). Resolves the current user's
// token, email, and owner status on open, and provides helpers for launching
// the feedback website and closing the drawer safely.

import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';
import 'package:url_launcher/url_launcher.dart';

class SliderMenuViewModel extends ChangeNotifier {
  String _token = "";
  String? _email = "";
  bool? _isOwner;
  bool _isLoading = false;
  // Prevents notifyListeners() from firing after the widget tree is disposed
  bool _disposed = false;

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_isLoading) return;
      try {
        _isLoading = true;
        _token = sm.token;
        notifyListeners();
        await sm.checkIfValidToken();
        _email = sm.email;
        _isOwner = sm.role == 'teacher';
        notifyListeners();
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  /// Validates the session token, then executes onValid if the token is still good.
  bool validateAndNavigate(
    BuildContext context,
    VoidCallback onValid, {
    bool requiresOwnerResolved = false,
  }) {
    sm.checkIfValidToken();
    if (requiresOwnerResolved && _isOwner == null) {
      notify.showToast("Check your internet connection", isError: true);
      return false;
    }
    onValid();
    return true;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // Overridden to guard against async callbacks firing after dispose()
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }
}
