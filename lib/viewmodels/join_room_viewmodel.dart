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

  Future<void> joinRoom( int id) async {
    try {
      if (_isLoading) return;
      _isLoading = true;
      notifyListeners();
      await api.joinRoomById( id);
      _isLoading = false;
      notifyListeners();
      notify.showToast('Room joined.');
      if (sm.role == "teacher") {
        nav.toOwnerConsultations(
        );
      } else {
        nav.toBaseConsultations(
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

  Future<void> fetchAllRooms() async {
    _allRooms = await api.getAllRooms();
    notifyListeners();
  }

  Future<void> fetchJoinedRooms() async {
    _joinedRooms = await api.getJoinedRooms();
    notifyListeners();
  }
}
