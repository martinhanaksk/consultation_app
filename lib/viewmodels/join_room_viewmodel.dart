// join_room_viewmodel.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// ViewModel for the Join Room screen. Loads all available rooms and the
// user's already-joined rooms, handles room selection, and on join failure
// shows which email domains are permitted for the selected room.

import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/setup.dart';
import 'package:flutter/material.dart';

class JoinRoomViewmodel extends ChangeNotifier {
  // ── State ────────────────────────────────────────────────────────────────────────────

  List<RoomModel> _allRooms = [];
  List<RoomModel> _joinedRooms = [];
  bool _isLoading = false;
  // Separate flag so the room list shows independently of join-action loading
  bool _isLoadingRooms = false;
  int? _selectedId;

  final TextEditingController idController = TextEditingController();

  // ── Getters ──────────────────────────────────────────────────────────────────────────

  bool get isLoading => _isLoading;
  bool get isLoadingRooms => _isLoadingRooms;
  int? get selectedId => _selectedId;
  List<RoomModel> get allRooms => _allRooms;
  List<RoomModel> get joinedRooms => _joinedRooms;

  // ── Lifecycle ────────────────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    idController.dispose();
    super.dispose();
  }

  // ── Public Methods ───────────────────────────────────────────────────────────────────────────

  Future<void> init() async {
    _isLoadingRooms = true;
    notifyListeners();
    await fetchAllRooms();
    await fetchJoinedRooms();
    _isLoadingRooms = false;
    notifyListeners();
  }

  void setSelectedIds(RoomModel room) {
    _selectedId = room.id;
    notifyListeners();
  }

  void clearSelection() {
    _selectedId = null;
    notifyListeners();
  }

  bool isInJoinedRooms(RoomModel room) =>
      _joinedRooms.any((r) => r.id == room.id);

  Future<void> joinRoom(int id) async {
    // Prevent duplicate join requests if the button is tapped while already loading
    if (_isLoading) return;
    _setLoading(true);

    try {
      await api.joinRoomById(id);
      _setLoading(false);
      _navigateAfterJoin();
    } catch (_) {
      _setLoading(false);
      // Show the allowed email domains so the user knows why the join failed
      _showJoinError(id);
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

  // ── Private Helpers ────────────────────────────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Navigates to the correct home screen based on the user's role after joining
  void _navigateAfterJoin() {
    if (sm.role == 'teacher') {
      nav.toOwnerConsultations();
    } else {
      nav.toBaseConsultations();
    }
  }

  // Parses the room's acceptedEmails string and formats it as a readable list
  // in the toast so the user can see exactly which domains are permitted
  void _showJoinError(int id) {
    try {
      final room = _allRooms.firstWhere((r) => r.id == id);
      final formatted = room.acceptedEmails
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .join('\n• ');
      notify.showToast(
        'Email addresses/domains allowed:\n\n• $formatted',
        title: 'Access Restricted',
      );
    } catch (_) {
      notify.showToast('You cannot join this room');
    }
  }
}
