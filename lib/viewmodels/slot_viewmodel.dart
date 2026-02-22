import 'package:consultation_app/setup.dart';
import 'package:flutter/material.dart';

class SlotViewmodel extends ChangeNotifier {
  bool _isLoading = false;
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
    } notifyListeners();
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
    } notifyListeners();
  }
}
