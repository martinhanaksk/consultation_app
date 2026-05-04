import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/setup.dart';
import 'package:flutter/material.dart';

class JoinRoomViewmodel extends ChangeNotifier {
  List<RoomModel>? _allRooms = [];
  List<RoomModel>? _joinedRooms = [];
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isLoadingRooms = false;
  bool get isLoadingRooms => _isLoadingRooms;
  String? _selectedRoomId;
  String? get selectedRoomId => _selectedRoomId;
  int? _selectedId;
  int? get selectedId => _selectedId;
  final TextEditingController idController = TextEditingController();
  List<RoomModel>? allRooms() {
    return _allRooms;
  }

  @override
  void dispose() {
    idController.dispose();
    super.dispose();
  }

  void clearSelection() {
    _selectedRoomId = null;
    _selectedId = null;
    notifyListeners();
  }

  List<RoomModel>? joinedRooms() {
    return _joinedRooms;
  }

  void setSelectedIds(RoomModel room) {
    _selectedRoomId = room.id.toString();
    _selectedId = room.id;
    notifyListeners();
  }

  Future<void> joinRoom(int id) async {
    try {
      if (_isLoading) return;
      _isLoading = true;
      notifyListeners();
      await api.joinRoomById(id);
      _isLoading = false;
      notifyListeners();
      if (sm.role == "teacher") {
        nav.toOwnerConsultations();
      } else {
        nav.toBaseConsultations();
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      try {
        if (_allRooms == null) {
          notify.showToast('You cannot join this room');
        }
        final room = _allRooms!.firstWhere((r) => r.id == id);

        final emailList = room.acceptedEmails
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        final formattedList = emailList.join('\n• ');
        notify.showToast(
          title: 'Access Restricted',

          'You cannot join this room.\n\nOnly accounts matching these email addresses or domains are allowed:\n\n• $formattedList',
        );
      } catch (_) {
        notify.showToast('You cannot join this room');
      }
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

  void init() async {
    _isLoadingRooms = true;
    notifyListeners();
    await fetchAllRooms();
    await fetchJoinedRooms();
    _isLoadingRooms = false;
    notifyListeners();
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
