// display_users_in_room_viewmodel.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// ViewModel for the Users in Room screen. Fetches and exposes the list of
// users joined to a given room.

import 'package:consultation_app/setup.dart';
import 'package:flutter/foundation.dart';

class DisplayUsersInRoomViewModel extends ChangeNotifier {
  List<String> _users = [];
  bool _isLoading = false;
  bool _hasError = false;
  List<String> get users => _users;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  Future<void> init(int roomId) async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    try {
      _users = await api.getConnectedUsersInRoom(roomId);
      _hasError = false;
    } catch (e) {
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
