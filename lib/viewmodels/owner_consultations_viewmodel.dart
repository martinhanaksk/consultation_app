// owner_consultations_viewmodel.dart
import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/models/slot_model.dart';
import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/base_consultations_viewmodel.dart';

class OwnerConsultationsViewmodel extends BaseConsultationsViewmodel {
  //0=visitor, 1=owner
  List<RoomModel> _ownerRooms = [];
  List<RoomModel> _visitorRooms = [];
  @override
  Future<List<RoomModel>> fetchRooms() async {
    return ownerView == 0 ? _visitorRooms : _ownerRooms;
  }

  Future<void> deleteRoom() async {
    isLoading = true;
    notifyListeners();
    try {
      bool b = await api.deleteRoom(selectedRoomId!);
      if (b) {
        nav.pop();
        notify.showToast('Room was successfully deleted');
      }
    } catch (e) {
      nav.pop();
      notify.showToast('Error while deleting room',isError: true);
    } finally {
      isLoading = false;
      notifyListeners();
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
      String now = DateTime.now().toString().substring(0, 10);
      final slots = await api.getSlotsForBlock(blockId, now);
      if (slots != null) {
        final slot = slots.firstWhere((s) => s.id == slotId);
        nav.toDisplaySlotHistory(history: slot.history ?? "");
      }
    } finally {}
  }

  @override
  Future<void> init() async {
    isLoading = true;
    notifyListeners();
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
      
      visitorSelectedRoomId = _visitorRooms.isNotEmpty
          ? sm.roomIdVisitor ?? _visitorRooms[0].id
          : null;
      ownerSelectedRoomId = _ownerRooms.isNotEmpty
          ? sm.roomIdOwner ?? _ownerRooms[0].id
          : null;
      selectedRoomId = ownerView == 1
          ? ownerSelectedRoomId
          : visitorSelectedRoomId;

      if (selectedRoomId != null) {
        await refreshRoomData(selectedRoomId!);
      }
    } catch (e) {
      notify.showToast('Failed to load consultations. Please try again.',isError: true);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSlotBeforeBlock(int blockId) =>
      _addSlotAtMargin(blockId, atEnd: false);

  Future<void> addSlotAfterBlock(int blockId) =>
      _addSlotAtMargin(blockId, atEnd: true);

  Future<void> _addSlotAtMargin(int blockId, {required bool atEnd}) async {
    atEnd
        ? setAddingSlotAfter(blockId, true)
        : setAddingSlotBefore(blockId, true);

    try {
      final now = DateTime.now().toString().substring(0, 10);
      final slotsForBlock = await api.getSlotsForBlock(blockId, now);

      if (slotsForBlock == null || slotsForBlock.isEmpty) {
        notify.showToast("No slots found in block");
        return;
      }

      final anchorSlot = atEnd ? slotsForBlock.last : slotsForBlock.first;
      final newStartTime = calculateMarginTimes(
        atEnd ? 1 : 0,
        anchorSlot.startTime,
        anchorSlot.duration,
      );

      if (newStartTime == null) {
        notify.showToast(
          atEnd
              ? "Cannot add a slot after 24:00"
              : "Cannot add a slot before 00:00",
        );
        return;
      }

      final tempSlot = SlotModel(
        id: -DateTime.now().millisecondsSinceEpoch,
        blockId: blockId,
        roomId: selectedRoomId ?? 0,
        startTime: newStartTime,
        duration: anchorSlot.duration,
        isOnline: anchorSlot.isOnline,
        isOnlineTeacher: anchorSlot.isOnlineTeacher,
        note: "",
        takenBy: null,
        takenByName: null,
        takenByReason: null,
        history: null,
      );

      final currentSlots = slotsInBlocks[blockId] ?? [];
      atEnd ? currentSlots.add(tempSlot) : currentSlots.insert(0, tempSlot);
      slotsInBlocks[blockId] = currentSlots;
      notifyListeners();

      final slotCreated = await api.createSlot(
        blockId,
        newStartTime,
        anchorSlot.duration,
        anchorSlot.isOnline,
        "",
      );

      if (!slotCreated) {
        currentSlots.removeWhere((s) => s.id == tempSlot.id);
        slotsInBlocks[blockId] = currentSlots;
        notifyListeners();
        notify.showToast("Could not create new slot",isError: true);
        return;
      }

      await refreshBlock(blockId);
    } catch (e) {
      notify.showToast("Error adding slot",isError: true);
      await refreshBlock(blockId);
    } finally {
      atEnd
          ? setAddingSlotAfter(blockId, false)
          : setAddingSlotBefore(blockId, false);
    }
  }

  String? calculateMarginTimes(int isEndTime, String oldTime, int duration) {
    final parts = oldTime.split(':');
    final originalStart = Duration(
      hours: int.parse(parts[0]),
      minutes: int.parse(parts[1]),
      seconds: int.parse(parts[2]),
    );
    Duration newStart;
    if (isEndTime == 0) {
      newStart = originalStart - Duration(minutes: duration);
    } else if (isEndTime == 1) {
      newStart = originalStart + Duration(minutes: duration);
    } else {
      return "";
    }
    if (newStart.isNegative || newStart.inHours > 23) return null;

    return '${newStart.inHours.toString().padLeft(2, '0')}:'
        '${(newStart.inMinutes % 60).toString().padLeft(2, '0')}:'
        '${(newStart.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  void toggleView(int value) async {
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

    final isValid = rooms!.any((r) => r.id == selectedRoomId);
    if (!isValid) {
      final firstId = rooms![0].id;
      if (value == 1) {
        ownerSelectedRoomId = firstId;
      } else {
        visitorSelectedRoomId = firstId;
      }
      selectedRoomId = firstId;
    }

    notifyListeners();

    isLoading = true;
    notifyListeners();
    await loadRoom();
    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshBlock(int blockId) async {
    try {
      String now = DateTime.now().toString().substring(0, 10);
      final freshSlots = await api.getSlotsForBlock(blockId, now);
      if (freshSlots != null) {
        slotsInBlocks[blockId] = freshSlots;
        notifyListeners();
      }
    } catch (e) {}
  }
}
