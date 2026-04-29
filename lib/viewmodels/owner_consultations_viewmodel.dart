// owner_consultations_viewmodel.dart
import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/base_consultations_viewmodel.dart';

class OwnerConsultationsViewmodel extends BaseConsultationsViewmodel {
  //0=visitor, 1=owner
  List<RoomModel> _ownerRooms = [];
  List<RoomModel> _visitorRooms = [];
  @override
  Future<List<RoomModel>> fetchRooms(String token) async {
    return ownerView == 0 ? _visitorRooms : _ownerRooms;
  }

  Future<void> deleteRoom(String token) async {
    isLoading = true;
    notifyListeners();
    try {
      bool b = await api.deleteRoom(token, int.parse(safeSelectedRoomId!));
      if (b) {
        nav.pop();
        notify.showToast('Room was successfully deleted.');
      }
    } catch (e) {
      nav.pop();
      notify.showToast('Error while deleting room.');
    } finally {
      isLoading = false;
      notifyListeners();
      nav.toOwnerConsultations(
        token: token,
        email: await prefs.getItem("email"),
      );
    }
  }

  Future<void> displayHistoryOfSlot(
    String token,
    int slotId,
    int blockId,
  ) async {
    try {
      final slots = await api.getSlotsForBlock(token, blockId);
      if (slots != null) {
        final slot = slots.firstWhere((s) => s.id == slotId);
        nav.toDisplaySlotHistory(history: slot.history ?? "");
      }
    } finally {}
  }

  // owner_consultations_viewmodel.dart
  @override
  Future<void> init(String token, String email) async {
    isLoading = true;
    notifyListeners();
    if (!await checkConnection()) return;

    helpers.checkIfValidToken(token);
    isOwner = await resolveUserRole(token, email);

    _visitorRooms = await api.getJoinedRooms(token);
    _ownerRooms = await api.getMyRoomsOwner(token);

    if (_visitorRooms.isEmpty && _ownerRooms.isEmpty) {
      noRoomsFound = true;
      isLoading = false;
      notifyListeners();
      return;
    }

    visitorSelectedRoomId = _visitorRooms.isNotEmpty
        ? _visitorRooms[0].id.toString()
        : null;
    ownerSelectedRoomId = _ownerRooms.isNotEmpty
        ? _ownerRooms[0].id.toString()
        : null;
    selectedRoomId = ownerView == 1
        ? ownerSelectedRoomId
        : visitorSelectedRoomId;

    if (selectedRoomId != null) {
      await refreshRoomData(token, int.parse(selectedRoomId!));
    }

    isLoading = false;
    notifyListeners();
  }

  // In OwnerConsultationsViewmodel

  Future<void> addSlotBeforeBlock(String token, int blockId) async {
    setAddingSlotBefore(blockId, true);
    try {
      final slotsForBlock = await api.getSlotsForBlock(token,blockId);
      if (slotsForBlock == null || slotsForBlock.isEmpty) {
        notify.showToast("No slots found in block.");
        return;
      }
      final newStartTime = calculateMarginTimes(
        0,
        slotsForBlock[0].startTime,
        slotsForBlock[0].duration,
      );
      if (newStartTime == null) {
        notify.showToast("Cannot add a slot before 00:00.");
        return;
      }
      final slotCreated = await api.createSlot(
        token,
        blockId,
        newStartTime,
        slotsForBlock[0].duration,
        slotsForBlock[0].isOnline,
        slotsForBlock[0].note ?? " ",
      );
      if (!slotCreated) {
        notify.showToast("Could not create new slot.");
        return;
      }
      await loadRoom(token);
    } catch (e) {
      notify.showToast("Error adding slot.");
    } finally {
      setAddingSlotBefore(blockId, false);
    }
  }

  Future<void> addSlotAfterBlock(String token, int blockId) async {
    setAddingSlotAfter(blockId, true);
    try {
      final slotsForBlock = await api.getSlotsForBlock(token,blockId);
      if (slotsForBlock == null || slotsForBlock.isEmpty) {
        notify.showToast("No slots found in block.");
        return;
      }
      final lastSlot = slotsForBlock.last;
      final newStartTime = calculateMarginTimes(
        1,
        lastSlot.startTime,
        lastSlot.duration,
      );
      if (newStartTime == null) {
        notify.showToast("Cannot add a slot after 24:00.");
        return;
      }
      final slotCreated = await api.createSlot(
        token,
        blockId,
        newStartTime,
        lastSlot.duration,
        lastSlot.isOnline,
        lastSlot.note ?? " ",
      );
      if (!slotCreated) {
        notify.showToast("Could not create new slot.");
        return;
      }
      await loadRoom(token);
    } catch (e) {
      notify.showToast("Error adding slot.");
    } finally {
      setAddingSlotAfter(blockId, false);
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

  String? getRoomNameById() {
    return rooms
        ?.cast<RoomModel?>()
        .firstWhere(
          (r) => r!.id.toString() == safeSelectedRoomId,
          orElse: () => null,
        )
        ?.title;
  }

  void toggleView(String token, int value) async {
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

    final isValid = rooms!.any((r) => r.id.toString() == selectedRoomId);
    if (!isValid) {
      final firstId = rooms![0].id.toString();
      if (value == 1)
        ownerSelectedRoomId = firstId;
      else
        visitorSelectedRoomId = firstId;
      selectedRoomId = firstId;
    }

    notifyListeners();

    isLoading = true;
    notifyListeners();
    await loadRoom(token);
    isLoading = false;
    notifyListeners();
  }
}
