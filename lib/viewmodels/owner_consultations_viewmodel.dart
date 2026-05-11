// owner_consultations_viewmodel.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Extends BaseConsultationsViewModel for the owner view. Maintains separate
// room lists for owner and visitor modes, overrides init() and fetchRooms()
// and adds owner-only actions: room deletion, view toggling,
// slot history, and inserting slots before/after a block.

import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/models/slot_model.dart';
import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/base_consultations_viewmodel.dart';

class OwnerConsultationsViewModel extends BaseConsultationsViewModel {
  // Two separate room lists so switching views does not require a network call
  List<RoomModel> _ownerRooms = [];
  List<RoomModel> _visitorRooms = [];
  // ── Overrides ───────────────────────────────────────────────────────────────────────────
  // Returns the correct cached room list for the active view mode
  @override
  Future<List<RoomModel>> fetchRooms() async =>
      ownerView == 0 ? _visitorRooms : _ownerRooms;
  // Overrides base init() to fetch both owner and visitor room lists in parallel
  // and resolve each mode's initial selected room from session storage
  @override
  Future<void> init() async {
    setLoading(true);
    try {
      if (!await checkConnection()) return;

      sm.checkIfValidToken();
      isOwner = await resolveUserRole(sm.email);
      _visitorRooms = await api.getJoinedRooms();
      _ownerRooms = await api.getMyRoomsOwner();
      if (_visitorRooms.isEmpty && _ownerRooms.isEmpty) {
        noRoomsFound = true;
        return;
      }

      // Restore last-visited room per mode from session; fall back to first available
      visitorSelectedRoomId = _visitorRooms.isNotEmpty
          ? sm.roomIdVisitor ?? _visitorRooms.first.id
          : null;
      ownerSelectedRoomId = _ownerRooms.isNotEmpty
          ? sm.roomIdOwner ?? _ownerRooms.first.id
          : null;
      selectedRoomId = ownerView == 1
          ? ownerSelectedRoomId
          : visitorSelectedRoomId;
      if (selectedRoomId != null) await refreshRoomData(selectedRoomId!);
    } catch (e) {
      notify.showToast(
        'Failed to load consultations. Please try again.',
        isError: true,
      );
    } finally {
      setLoading(false);
    }
  }

  // ── Public Methods ───────────────────────────────────────────────────────────────────────────
  Future<void> deleteRoom() async {
    setLoading(true);
    try {
      final deleted = await api.deleteRoom(selectedRoomId!);
      nav.pop();
      notify.showToast(
        deleted ? 'Room was successfully deleted' : 'Error while deleting room',
      );
    } catch (_) {
      nav.pop();
      notify.showToast('Error while deleting room', isError: true);
    } finally {
      setLoading(false);
      // Always navigate back to the owner list so the deleted room is no longer shown
      nav.toOwnerConsultations();
    }
  }

  String? getRoomNameById() {
    return rooms
        ?.cast<RoomModel?>()
        .firstWhere((r) => r!.id == selectedRoomId, orElse: () => null)
        ?.title;
  }

  Future<void> displayHistoryOfSlot(int slotId, int blockId) async {
    try {
      // Re-fetch the block's slots to get the latest history string
      final slots = await api.getSlotsForBlock(blockId, _todayString());
      if (slots == null) return;
      final slot = slots.firstWhere((s) => s.id == slotId);
      nav.toDisplaySlotHistory(history: slot.history ?? '');
    } catch (_) {
      notify.showToast("Slot not found", isError: true);
    }
  }

  Future<void> addSlotBeforeBlock(int blockId) =>
      _addSlotAtMargin(blockId, atEnd: false);
  Future<void> addSlotAfterBlock(int blockId) =>
      _addSlotAtMargin(blockId, atEnd: true);
  Future<void> toggleView(int value) async {
    await setOwnerView(value);

    // Switch to the pre-fetched room list for the new view mode
    rooms = value == 1 ? _ownerRooms : _visitorRooms;
    if (rooms == null || rooms!.isEmpty) {
      noRoomsFound = true;
      blocks = [];
      slotsInBlocks = {};
      notifyListeners();
      return;
    }
    noRoomsFound = false;
    selectedRoomId = value == 1 ? ownerSelectedRoomId : visitorSelectedRoomId;

    // If the previously selected room no longer exists in the new list, fall back to the first
    if (!rooms!.any((r) => r.id == selectedRoomId)) {
      final fallbackId = rooms!.first.id;
      if (value == 1) {
        ownerSelectedRoomId = fallbackId;
      } else {
        visitorSelectedRoomId = fallbackId;
      }
      selectedRoomId = fallbackId;
    }
    setLoading(true);
    await loadRoom();
    setLoading(false);
  }

  Future<void> refreshBlock(int blockId) async {
    try {
      final freshSlots = await api.getSlotsForBlock(blockId, _todayString());
      if (freshSlots != null) {
        slotsInBlocks[blockId] = freshSlots;
        notifyListeners();
      }
    } catch (_) {}
  }

  // Calculates the start time for a new slot inserted before (isEndTime == 0)
  // or after (isEndTime == 1) an existing slot given its start time and duration.
  // Returns null if the computed time would fall outside 00:00–23:59.
  String? calculateMarginTimes(int isEndTime, String oldTime, int duration) {
    final parts = oldTime.split(':');
    final originalStart = Duration(
      hours: int.parse(parts[0]),
      minutes: int.parse(parts[1]),
      seconds: int.parse(parts[2]),
    );
    final Duration newStart;
    if (isEndTime == 0) {
      newStart = originalStart - Duration(minutes: duration);
    } else if (isEndTime == 1) {
      newStart = originalStart + Duration(minutes: duration);
    } else {
      return '';
    }

    // Reject times that overflow or underflow the 24-hour clock
    if (newStart.isNegative || newStart.inHours > 23) return null;
    return '${newStart.inHours.toString().padLeft(2, '0')}:'
        '${(newStart.inMinutes % 60).toString().padLeft(2, '0')}:'
        '${(newStart.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  // ── Private Helpers ────────────────────────────────────────────────────────────────────────────

  String _todayString() => DateTime.now().toString().substring(0, 10);
  // Inserts a slot immediately before or after the block's boundary slot.
  // Uses an optimistic placeholder that is replaced once the
  // API confirms creation, or removed if creation fails.
  Future<void> _addSlotAtMargin(int blockId, {required bool atEnd}) async {
    atEnd
        ? setAddingSlotAfter(blockId, true)
        : setAddingSlotBefore(blockId, true);
    try {
      final slots = await api.getSlotsForBlock(blockId, _todayString());
      if (slots == null || slots.isEmpty) {
        notify.showToast('No slots found in block');
        return;
      }

      // Anchor to the last slot when appending, first slot when prepending
      final anchor = atEnd ? slots.last : slots.first;
      final newStartTime = calculateMarginTimes(
        atEnd ? 1 : 0,
        anchor.startTime,
        anchor.duration,
      );
      if (newStartTime == null) {
        notify.showToast(
          atEnd
              ? 'Cannot add a slot after 24:00'
              : 'Cannot add a slot before 00:00',
        );
        return;
      }

      // Negative millisecond ID serves as a unique temporary key that cannot
      // conflict with any real server-issued ID
      final tempSlot = SlotModel(
        id: -DateTime.now().millisecondsSinceEpoch,
        blockId: blockId,
        roomId: selectedRoomId ?? 0,
        startTime: newStartTime,
        duration: anchor.duration,
        isOnline: anchor.isOnline,
        isOnlineTeacher: anchor.isOnlineTeacher,
        note: '',
        takenBy: null,
        takenByName: null,
        takenByReason: null,
        history: null,
      );

      // Optimistically insert the placeholder so the UI responds immediately
      final currentSlots = slotsInBlocks[blockId] ?? [];
      atEnd ? currentSlots.add(tempSlot) : currentSlots.insert(0, tempSlot);
      slotsInBlocks[blockId] = currentSlots;
      notifyListeners();
      final created = await api.createSlot(
        blockId,
        newStartTime,
        anchor.duration,
        anchor.isOnline,
        '',
      );

      // Remove the placeholder and show an error if the API call failed
      if (!created) {
        currentSlots.removeWhere((s) => s.id == tempSlot.id);
        slotsInBlocks[blockId] = currentSlots;
        notifyListeners();
        notify.showToast('Could not create new slot', isError: true);
        return;
      }

      // Replace the placeholder with the real slot data from the server
      try {
        await refreshBlock(blockId);
      } catch (e) {
        currentSlots.removeWhere((s) => s.id == tempSlot.id);
        slotsInBlocks[blockId] = currentSlots;
        notifyListeners();
        notify.showToast('Slot created but failed to refresh', isError: true);
      }
    } catch (_) {
      notify.showToast('Error adding slot', isError: true);
      await refreshBlock(blockId);
    } finally {
      atEnd
          ? setAddingSlotAfter(blockId, false)
          : setAddingSlotBefore(blockId, false);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
