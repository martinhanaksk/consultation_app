// teacher_consultations_viewmodel.dart
import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/base_consultations_viewmodel.dart';

class TeacherConsultationsViewmodel extends BaseConsultationsViewmodel {
  //0=visitor, 1=owner

  @override
  Future<List<RoomModel>> fetchRooms(String token) =>
      ownerView == 0 ? api.getJoinedRooms(token) : api.getMyRoomsTeacher(token);

  Future<void> deleteRoom(String token) async {
    try {
      bool b = await api.deleteRoom(token, int.parse(safeSelectedRoomId!));
      if (b) {
        notify.showToast('Room was successfully deleted.');
      }
    } catch (e) {
      notify.showToast('Error while deleting room.');
    }
  }

  // teacher_consultations_viewmodel.dart
  @override
  Future<void> init(String token, String email) async {
    if (await prefs.containsItem("ownerView") == false) {
      await setOwnerView(0);
    } else {
      await setOwnerView(int.parse(await prefs.getItem('ownerView')));
    }

    isLoading = true;
    notifyListeners();
    if (!await checkConnection()) return;

    helpers.checkIfValidToken(token);
    isTeacher = await resolveUserRole(token, email);

    final fetchedVisitorRooms = await api.getJoinedRooms(token);
    final fetchedOwnerRooms = await api.getMyRoomsTeacher(token);

    if (fetchedVisitorRooms.isEmpty && fetchedOwnerRooms.isEmpty) {
      noRoomsFound = true;
      isLoading = false;
      notifyListeners();
      return;
    }

    visitorSelectedRoomId = fetchedVisitorRooms.isNotEmpty
        ? fetchedVisitorRooms[0].id.toString()
        : null;
    ownerSelectedRoomId = fetchedOwnerRooms.isNotEmpty
        ? fetchedOwnerRooms[0].id.toString()
        : null;

    selectedRoomId = ownerView == 1
        ? ownerSelectedRoomId
        : visitorSelectedRoomId;

    final firstRoomId =
        selectedRoomId ?? visitorSelectedRoomId ?? ownerSelectedRoomId;
    selectedRoomId ??= firstRoomId;
    if (selectedRoomId == ownerSelectedRoomId && ownerView == 0) {
      await setOwnerView(1);
    }
    await refreshRoomData(token, int.parse(firstRoomId!));
    isLoading = false;
    notifyListeners();
  }

  Future<void> addSlotBeforeBlock(String token, int blockId) async {
    final slotsForBlock = await api.getSlotsForBlock(blockId, token);
    if (slotsForBlock != null && slotsForBlock.isNotEmpty) {
      final newStartTime = calculateMarginTimes(
        0,
        slotsForBlock[0].startTime,
        slotsForBlock[0].duration,
      );
      if (newStartTime == null) {
        notify.showToast("Cannot add a slot before 00:00.");
        return;
      }
      bool slotCreated = await api.createSlot(
        token,
        blockId,
        newStartTime,
        slotsForBlock[0].duration,
        slotsForBlock[0].isOnline,
        slotsForBlock[0].note ?? " ",
      );
      if (!slotCreated) {
        notify.showToast("Could not create new slot.");
        setIsLoading(false);
      }
    } else {
      return;
    }
  }

  Future<void> addSlotAfterBlock(String token, int blockId) async {
    final slotsForBlock = await api.getSlotsForBlock(blockId, token);
    if (slotsForBlock != null && slotsForBlock.isNotEmpty) {
      final newStartTime = calculateMarginTimes(
        1,
        slotsForBlock[slotsForBlock.length - 1].startTime,
        slotsForBlock[slotsForBlock.length - 1].duration,
      );
      if (newStartTime == null) {
        notify.showToast("Cannot add a slot after 24:00.");
        return;
      }
      bool slotCreated = await api.createSlot(
        token,
        blockId,
        newStartTime,
        slotsForBlock[0].duration,
        slotsForBlock[0].isOnline,
        slotsForBlock[0].note ?? " ",
      );
      if (!slotCreated) {
        notify.showToast("Could not create new slot.");
        setIsLoading(false);
      }
    } else {
      return;
    }
  }

  String? calculateMarginTimes(int isEndTime, String oldTime, int duration) {
    String result = "";
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
    if (newStart.isNegative || newStart.inHours > 24) return null;

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
    isLoading = true;
    notifyListeners();

    await setOwnerView(value);
    selectedRoomId = value == 1 ? ownerSelectedRoomId : visitorSelectedRoomId;

    final fetchedRooms = await fetchRooms(token);

    if (fetchedRooms.isEmpty) {
      rooms = [];
      noRoomsFound = true;
      isLoading = false;
      notifyListeners();
      return;
    }

    final isValid = fetchedRooms.any((r) => r.id.toString() == selectedRoomId);

    if (!isValid) {
      final firstId = fetchedRooms[0].id.toString();
      if (value == 1) {
        ownerSelectedRoomId = firstId;
      } else {
        visitorSelectedRoomId = firstId;
      }
      selectedRoomId = firstId;
    }

    await loadRoom(token);
    isLoading = false;
    notifyListeners();
  }
}
