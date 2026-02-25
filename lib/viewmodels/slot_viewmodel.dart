import 'package:consultation_app/setup.dart';
import 'package:flutter/material.dart';

class SlotViewmodel extends ChangeNotifier {
  bool _isLoading = false;
  bool _temporarybellboolean = false;
  void setTemporarybellboolean(bool val) {
    _temporarybellboolean = val;
    notifyListeners();
  }

  bool get temporaryBellBoolean => _temporarybellboolean;
  Future<void> takeSlot(String token, int id, String note) async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    try {
      await api.takeSlot(token, id, note);
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      rethrow;
    }
    notifyListeners();
  }

  Future<void> releaseSlot(String token, int id) async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    try {
      await api.releaseSlot(token, id);
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      rethrow;
    }
    notifyListeners();
  }

  void handleEmailSubscribe(String token, int block) async {
    bool receiveEmails = await prefs.getItem('receiveEmails');
    if (receiveEmails == true) {
      api.subscribeToBlock(token, block);
      setTemporarybellboolean(true);
    } else {
      notify.showToast("Turn on email recieving in the settings");
    }
  }
}
