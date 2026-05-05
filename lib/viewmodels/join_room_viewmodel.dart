import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/setup.dart';
import 'package:flutter/material.dart';

class JoinRoomViewmodel extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────

  List<RoomModel> _allRooms = [];
  List<RoomModel> _joinedRooms = [];
  bool _isLoading = false;
  bool _isLoadingRooms = false;
  String? _selectedRoomId;
  int? _selectedId;

  final TextEditingController idController = TextEditingController();

  // ── Getters ────────────────────────────────────────────────────────────────

  bool get isLoading => _isLoading;
  bool get isLoadingRooms => _isLoadingRooms;
  String? get selectedRoomId => _selectedRoomId;
  int? get selectedId => _selectedId;
  List<RoomModel> get allRooms => _allRooms;
  List<RoomModel> get joinedRooms => _joinedRooms;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void dispose() {
    idController.dispose();
    super.dispose();
  }

  // ── Public Methods ─────────────────────────────────────────────────────────

  Future<void> init() async {
    _isLoadingRooms = true;
    notifyListeners();
    await fetchAllRooms();
    await fetchJoinedRooms();
    _isLoadingRooms = false;
    notifyListeners();
  }

  void setSelectedIds(RoomModel room) {
    _selectedRoomId = room.id.toString();
    _selectedId = room.id;
    notifyListeners();
  }

  void clearSelection() {
    _selectedRoomId = null;
    _selectedId = null;
    notifyListeners();
  }

  bool isInJoinedRooms(RoomModel room) =>
      _joinedRooms.any((r) => r.id == room.id);

  Future<void> joinRoom(int id) async {
    if (_isLoading) return;
    _setLoading(true);

    try {
      await api.joinRoomById(id);
      _setLoading(false);
      _navigateAfterJoin();
    } catch (_) {
      _setLoading(false);
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

  // ── Private Helpers ────────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _navigateAfterJoin() {
    if (sm.role == 'teacher') {
      nav.toOwnerConsultations();
    } else {
      nav.toBaseConsultations();
    }
  }

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
