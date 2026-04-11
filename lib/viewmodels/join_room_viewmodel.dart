import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/setup.dart';
import 'package:flutter/material.dart';

class JoinRoomViewmodel extends ChangeNotifier {
  List<RoomModel>? _allRooms = [];
  List<RoomModel>? _joinedRooms = [];
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<RoomModel>? allRooms() {
    return _allRooms;
  }

  Future<void> joinRoom(String token, int id) async {
    try {
      if (_isLoading) return;
      _isLoading = true;
      notifyListeners();
      await api.joinRoomById(token, id);
      _isLoading = false;
      notifyListeners();
      notify.showToast('Room joined.');
      if (await prefs.getItem("role") == "teacher") {
        nav.toOwnerConsultations(
          token: token,
          email: await prefs.getItem("email"),
        );
      } else {
        nav.toBaseConsultations(
          token: token,
          email: await prefs.getItem("email"),
        );
      }
    } catch (e) {
      notify.showToast('Unable to join the room.');
    }
  }

  bool isInJoinedRooms(RoomModel option) {
    if (_joinedRooms != null) {
      final joinedIds = _joinedRooms!.map((room) => room.id).toList();
      if (joinedIds.contains(option.id)) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<void> fetchAllRooms(String token) async {
    _allRooms = await api.getAllRooms(token);
    notifyListeners();
  }

  Future<void> fetchJoinedRooms(String token) async {
    _joinedRooms = await api.getJoinedRooms(token);
    notifyListeners();
  }
}
