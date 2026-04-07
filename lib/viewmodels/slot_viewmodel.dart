import 'package:consultation_app/setup.dart';
import 'package:flutter/material.dart';

class SlotViewmodel extends ChangeNotifier {
  bool _isLoading = false;
  bool _isOnlineSelected = false;
  bool get isOnlineSelected => _isOnlineSelected;
  bool _optimisticallyReleased = false;
  bool get optimisticallyReleased => _optimisticallyReleased;
  bool _isTakingSlot = false;
  bool get isTakingSlot => _isTakingSlot;
  void setIsOnlineSelected(bool val) {
    _isOnlineSelected = val;
    notifyListeners();
  }

  Future<void> takeSlot(String token, int id, String note) async {
    if (_isLoading) return;
    _isLoading = true;
    _isTakingSlot = true;
    notifyListeners();
    try {
      await api.takeSlot(token, id, note, isOnlineSelected ? 1 : 0);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      _isTakingSlot = false;
      notifyListeners();
    }
  }

  Future<void> releaseSlot(String token, int id) async {
    if (_isLoading) return;
    _isLoading = true;
    _optimisticallyReleased = true;
    notifyListeners();
    try {
      await api.releaseSlot(token, id);
    } catch (e) {
      _optimisticallyReleased = false;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
