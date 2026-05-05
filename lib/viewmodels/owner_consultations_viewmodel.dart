// owner_consultations_viewmodel.dart
import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/models/slot_model.dart';
import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/base_consultations_viewmodel.dart';

class OwnerConsultationsViewmodel extends BaseConsultationsViewmodel {
  List<RoomModel> _ownerRooms = [];
  List<RoomModel> _visitorRooms = [];

  // ── Overrides ──────────────────────────────────────────────────────────────

  @override
  Future<List<RoomModel>> fetchRooms() async =>
      ownerView == 0 ? _visitorRooms : _ownerRooms;

  @override
  Future<void> init() async {
    _setLoading(true);
    if (!await checkConnection()) return;

    try {
      sm.checkIfValidToken();
      isOwner = await resolveUserRole(sm.email);

      _visitorRooms = await api.getJoinedRooms();
      _ownerRooms = await api.getMyRoomsOwner();

      if (_visitorRooms.isEmpty && _ownerRooms.isEmpty) {
        noRoomsFound = true;
        return;
      }

      visitorSelectedRoomId =
          _visitorRooms.isNotEmpty ? sm.roomIdVisitor ?? _visitorRooms.first.id : null;
      ownerSelectedRoomId =
          _ownerRooms.isNotEmpty ? sm.roomIdOwner ?? _ownerRooms.first.id : null;
      selectedRoomId = ownerView == 1 ? ownerSelectedRoomId : visitorSelectedRoomId;

      if (selectedRoomId != null) await refreshRoomData(selectedRoomId!);
    } catch (_) {
      notify.showToast('Failed to load consultations. Please try again.', isError: true);
    } finally {
      _setLoading(false);
    }
  }

  // ── Public Methods ─────────────────────────────────────────────────────────

  Future<void> deleteRoom() async {
    _setLoading(true);
    try {
      final deleted = await api.deleteRoom(selectedRoomId!);
      nav.pop();
      notify.showToast(deleted ? 'Room was successfully deleted' : 'Error while deleting room');
    } catch (_) {
      nav.pop();
      notify.showToast('Error while deleting room', isError: true);
    } finally {
      _setLoading(false);
      nav.toOwnerConsultations();
    }
  }

  String? getRoomNameById() {
    return rooms
        ?.cast<RoomModel?>()
        .firstWhere(
          (r) => r!.id == selectedRoomId,
          orElse: () => null,
        )
        ?.title;
  }

  Future<void> displayHistoryOfSlot(int slotId, int blockId) async {
    try {
      final slots = await api.getSlotsForBlock(blockId, _todayString());
      if (slots == null) return;
      final slot = slots.firstWhere((s) => s.id == slotId);
      nav.toDisplaySlotHistory(history: slot.history ?? '');
    } catch (_) {}
  }

  Future<void> addSlotBeforeBlock(int blockId) =>
      _addSlotAtMargin(blockId, atEnd: false);

  Future<void> addSlotAfterBlock(int blockId) =>
      _addSlotAtMargin(blockId, atEnd: true);

  Future<void> toggleView(int value) async {
    await setOwnerView(value);

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

    if (!rooms!.any((r) => r.id == selectedRoomId)) {
      final fallbackId = rooms!.first.id;
      if (value == 1) {
        ownerSelectedRoomId = fallbackId;
      } else {
        visitorSelectedRoomId = fallbackId;
      }
      selectedRoomId = fallbackId;
    }

    _setLoading(true);
    await loadRoom();
    _setLoading(false);
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

    if (newStart.isNegative || newStart.inHours > 23) return null;

    return '${newStart.inHours.toString().padLeft(2, '0')}:'
        '${(newStart.inMinutes % 60).toString().padLeft(2, '0')}:'
        '${(newStart.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  // ── Private Helpers ────────────────────────────────────────────────────────

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  String _todayString() => DateTime.now().toString().substring(0, 10);

  Future<void> _addSlotAtMargin(int blockId, {required bool atEnd}) async {
    atEnd ? setAddingSlotAfter(blockId, true) : setAddingSlotBefore(blockId, true);

    try {
      final slots = await api.getSlotsForBlock(blockId, _todayString());

      if (slots == null || slots.isEmpty) {
        notify.showToast('No slots found in block');
        return;
      }

      final anchor = atEnd ? slots.last : slots.first;
      final newStartTime = calculateMarginTimes(
        atEnd ? 1 : 0,
        anchor.startTime,
        anchor.duration,
      );

      if (newStartTime == null) {
        notify.showToast(
          atEnd ? 'Cannot add a slot after 24:00' : 'Cannot add a slot before 00:00',
        );
        return;
      }

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

      if (!created) {
        currentSlots.removeWhere((s) => s.id == tempSlot.id);
        slotsInBlocks[blockId] = currentSlots;
        notifyListeners();
        notify.showToast('Could not create new slot', isError: true);
        return;
      }

      await refreshBlock(blockId);
    } catch (_) {
      notify.showToast('Error adding slot', isError: true);
      await refreshBlock(blockId);
    } finally {
      atEnd ? setAddingSlotAfter(blockId, false) : setAddingSlotBefore(blockId, false);
    }
  }
}
