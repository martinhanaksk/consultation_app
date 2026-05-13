// my_reservations_viewmodel.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// ViewModel for the My Reservations screen.

import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/views/slots/type_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class MyReservationsViewModel extends ChangeNotifier {
  // ─── State ────────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> _reservations = [];
  bool _isLoading = false;
  late List<RoomModel> _cachedRooms;
  // Prevents notifyListeners() from firing after the widget tree is disposed
  bool _disposed = false;

  // Tracks per-slot pending operations so the UI can react immediately
  // before the server responds.

  final Map<int, bool> _optimisticallyReleased = {};
  final Map<int, bool> _changingType = {};

  // ─── Getters ──────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> get reservations =>
      List.unmodifiable(_reservations);
  bool get isLoading => _isLoading;
  bool isOptimisticallyReleased(int slotId) =>
      _optimisticallyReleased[slotId] ?? false;
  bool isChangingType(int slotId) => _changingType[slotId] ?? false;
  int slotId = 0;
  int roomId = 0;
  String roomName = "";
  bool isOnline = false;
  int duration = 0;
  String date = "";
  String note = "";
  String startTime = "";
  bool isReleasing = false;
  bool isChanging = false;

  // ─── Initialization ───────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_isLoading) return;
    _setLoading(true);

    try {
      final data = await api.getMyReservations(sm.token);
      await _getRooms();
      _reservations = data ?? [];
    } catch (_) {
      _reservations = [];
      notify.showToast("Could not load reservations", isError: true);
    } finally {
      _setLoading(false);
    }
  }

  // ─── Data Helpers ─────────────────────────────────────────────────────────

  // Fetches and caches all rooms from the API.
  Future<List<RoomModel>> _getRooms() async {
    _cachedRooms = await api.getAllRooms();
    return _cachedRooms;
  }

  // Extracts the display-relevant fields for a single reservation by index.
  Map<String, dynamic> slotEssentials(int index) {
    final slot = _reservations[index];
    final slotId = slot['id'] as int;
    final roomId = slot['room_id'] as int;
    final room = _cachedRooms.firstWhere((r) => r.id == roomId);
    return {
      'slotId': slotId,
      'roomName': room.title,
      'isOnline': slot['is_online'] == 1 || slot['is_online'] == true,
      'date': slot['date'] ?? '',
      'startTime': (slot['start_time'] as String? ?? '').length >= 5
          ? (slot['start_time'] as String).substring(0, 5)
          : slot['start_time'] ?? '',
      'duration': slot['duration'] ?? 0,
      'note': slot['note'] ?? '',
      'isReleasing': isOptimisticallyReleased(slotId),
      'isChanging': isChangingType(slotId),
    };
  }

  // ─── UI Actions ───────────────────────────────────────────────────────────

  // Opens the bottom sheet that lets the user switch between online/in-person.
  void openTypeSheet(BuildContext context, int slotId, bool isOnline) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ConsultationTypeBottomSheet(
        isOnline: isOnline ? 1 : 0,
        isOnlineTeacher: isOnline ? 1 : 0,
        name: '',
        reason: "",
        onChangeConsultationType: () => changeType(slotId),
        isTeacher: sm.role == 'teacher',
      ),
    );
  }

  // ─── API Actions ──────────────────────────────────────────────────────────

  // Optimistically removes the slot from the list, then confirms with the API.
  // Rolls back and shows a toast if the request fails.
  Future<void> releaseSlot(int slotId) async {
    _optimisticallyReleased[slotId] = true;
    notifyListeners();

    final backup = List<Map<String, dynamic>>.from(_reservations);
    _reservations = _reservations.where((s) => s['id'] != slotId).toList();
    notifyListeners();

    try {
      await api.releaseSlot(slotId);
      final data = await api.getMyReservations(sm.token);
      _reservations = data ?? [];
    } catch (_) {
      // Roll back on failure
      _reservations = backup;
      notify.showToast("Failed to cancel reservation", isError: true);
    } finally {
      _optimisticallyReleased.remove(slotId);
      notifyListeners();
    }
  }

  // Optimistically flips the is_online flag, then confirms with the API.
  // Rolls back and shows a toast if the request fails.
  Future<void> changeType(int slotId) async {
    _changingType[slotId] = true;
    notifyListeners();

    // Optimistically flip is_online in local cache
    final index = _reservations.indexWhere((s) => s['id'] == slotId);
    final backup = index != -1
        ? Map<String, dynamic>.from(_reservations[index])
        : null;
    if (index != -1) {
      final current = _reservations[index]['is_online'];
      _reservations[index] = {
        ..._reservations[index],
        'is_online': (current == 1 || current == true) ? 0 : 1,
      };
      notifyListeners();
    }

    try {
      await api.changeConsultationType(slotId);
      final data = await api.getMyReservations(sm.token);
      _reservations = data ?? [];
    } catch (_) {
      // Roll back
      if (index != -1 && backup != null) _reservations[index] = backup;
      notify.showToast("Failed to change meeting type", isError: true);
    } finally {
      _changingType.remove(slotId);
      notifyListeners();
    }
  }

  // ─── Private Helpers ──────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
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
