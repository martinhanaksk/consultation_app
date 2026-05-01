import 'package:consultation_app/models/block_model.dart';
import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/models/slot_model.dart';
import 'package:consultation_app/models/user_model.dart';
import 'package:consultation_app/setup.dart';
import 'package:flutter/foundation.dart';

class BaseConsultationsViewmodel extends ChangeNotifier {
  bool isOwner = false;
  bool isLoading = false;
  Map<int, bool> _addingSlotBefore = {};
  Map<int, bool> _addingSlotAfter = {};

  bool isAddingSlotBefore(int blockId) => _addingSlotBefore[blockId] ?? false;
  bool isAddingSlotAfter(int blockId) => _addingSlotAfter[blockId] ?? false;
  bool blocksFiltered = false;
  bool noRoomsFound = false;
  List<int> subscribedBlocks = [];
  List<UserModel>? users = [];
  List<RoomModel>? rooms = [];
  Map<int, List<SlotModel>?> slotsInBlocks = {};
  List<BlockModel> blocks = [];
  String? ownerSelectedRoomId;
  String? visitorSelectedRoomId;
  String _visitReason = "";
  String get visitReason => _visitReason;
  int _ownerView = 1;
  int get ownerView => _ownerView;
  String? selectedRoomId;
  Map<int, bool> _slotLoading = {};
  bool isSlotLoading(int slotId) => _slotLoading[slotId] ?? false;
  Map<int, bool> _optimisticallyReleased = {};
  bool isOptimisticallyReleased(int slotId) =>
      _optimisticallyReleased[slotId] ?? false;
  Map<int, bool> _takingSlot = {};
  bool isTakingSlot(int slotId) => _takingSlot[slotId] ?? false;
  Future<void> takeSlot(int slotId, String note, int isOnline) async {
    _takingSlot[slotId] = true;
    notifyListeners();
    try {
      await api.takeSlot(slotId, note, isOnline);
    } catch (e) {
      _takingSlot[slotId] = false;
      notify.showToast('manipulated');
      rethrow;
    } finally {
      _takingSlot.remove(slotId);
      notifyListeners();
      await loadRoom();
    }
  }

  Future<void> releaseSlot(int slotId) async {
    _optimisticallyReleased[slotId] = true;

    notifyListeners();
    try {
      await api.releaseSlot(slotId);
    } catch (e) {
      _optimisticallyReleased[slotId] = false;
      notify.showToast('Failed to release slot');
      rethrow;
    } finally {
      _optimisticallyReleased.remove(slotId);
      loadRoom();
    }
  }

  Future<void> onChangeConsultationType(int slotId) async {
    isLoading = true;
    notifyListeners();
    try {
      await api.changeConsultationType(slotId);
    } catch (e) {
      notify.showToast('Slot cannot be manipulated');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
      loadRoom();
    }
  }

  Future<void> handleEmailSubscribe(int block) async {
    final isCurrentlySubscribed = subscribedBlocks.contains(block);

    if (isCurrentlySubscribed) {
      subscribedBlocks.remove(block);
    } else {
      subscribedBlocks.add(block);
    }
    notifyListeners();

    try {
      await api.subscribeToBlock(block);
      subscribedBlocks = await api.getMySubscriptions();
      notifyListeners();
    } catch (e) {
      if (isCurrentlySubscribed) {
        subscribedBlocks.add(block);
      } else {
        subscribedBlocks.remove(block);
      }
      notifyListeners();
      notify.showToast('Failed to update subscription, please try again later');
    }
  }

  Future<void> setOwnerView(int value) async {
    if (_ownerView == value) return;
    _ownerView = value;
    notifyListeners();
  }

  void setAddingSlotBefore(int blockId, bool value) {
    _addingSlotBefore[blockId] = value;
    notifyListeners();
  }

  void setAddingSlotAfter(int blockId, bool value) {
    _addingSlotAfter[blockId] = value;
    notifyListeners();
  }

  void setIsLoading(bool value) {
    if (value) {
      isLoading = true;
    } else {
      isLoading = false;
    }
    notifyListeners();
  }

  Future<List<RoomModel>> fetchRooms() => api.getJoinedRooms();
  int? get roomIdNumber => ownerView == 0
      ? visitorSelectedRoomId == null
            ? null
            : int.parse(visitorSelectedRoomId!)
      : ownerSelectedRoomId == null
      ? null
      : int.parse(ownerSelectedRoomId!);

  int getBlocksCount() {
    if (blocksFiltered && blocks.isNotEmpty) {
      return blocks.length;
    }
    return 0;
  }

  Future<void> loadRoom() async {
    sm.checkIfValidToken();
    if (roomIdNumber != null) {
      await refreshRoomData(roomIdNumber!);
    }
  }

  Future<void> refreshRoomData(int roomId) async {
    isLoading = true; notifyListeners();
    if (!await checkConnection()) return;
    final subscriptions = await api.getMySubscriptions();
    final newUsers = await api.getUsers();
    final newRooms = await fetchRooms();
    _visitReason = sm.visitReason;
    if (newRooms.isEmpty) {
      noRoomsFound = true;
      notifyListeners();
      return;
    }

    noRoomsFound = false;
    String now = DateTime.now().toString().substring(0, 10);
    List<BlockModel> newBlocks = await api.getBlocks(roomId, now);

    Map<int, List<SlotModel>?> newSlotsInBlocks = {};
    List<Future<void>> futures = [];
    for (var block in newBlocks) {
      futures.add(() async {
        final slots = await api.getSlotsForBlock(block.id);
        if (slots != null) {
          slots.sort((a, b) => a.startTime.compareTo(b.startTime));
          newSlotsInBlocks[block.id] = slots;
        } else {
          newSlotsInBlocks[block.id] = [];
        }
      }());
    }
    await Future.wait(futures);
    subscribedBlocks = subscriptions;
    users = newUsers;
    rooms = newRooms;
    blocks = newBlocks;
    slotsInBlocks = newSlotsInBlocks;
    blocksFiltered = true; isLoading = false;
    notifyListeners();
  }

  String? get safeSelectedRoomId {
    if (rooms == null || selectedRoomId == null) return null;
    final exists = rooms!.any((r) => r.id.toString() == selectedRoomId);
    return exists ? selectedRoomId : null;
  }

  UserModel? getUserByEmail(String emailToFind) {
    if (users != null) {
      for (var tmpUser in users!) {
        if (tmpUser.email == emailToFind) {
          return tmpUser;
        }
      }
    }
    return null;
  }

  String blockDateLabel(int blockId) {
    for (var tmpBlock in blocks) {
      if (tmpBlock.id == blockId) {
        return "${helpers.getTDateOnlySimple(DateTime.parse(tmpBlock.date.toString()))} ${daysRemainingLabel(tmpBlock.date)}";
      }
    }
    return "";
  }

  String blockDate(int blockId) {
    for (var tmpBlock in blocks) {
      if (tmpBlock.id == blockId) {
        return "${DateTime.parse(tmpBlock.date.toString())}";
      }
    }
    return "";
  }

  String daysRemainingLabel(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    final diff = target.difference(today).inDays;
    if (diff < 0) return "";
    if (diff == 0) return "(today)";
    if (diff == 1) return "(tomorrow)";

    return "($diff d.)";
  }

  Future<void> switchRoom(String newRoomId) async {
    _ownerView == 1
        ? ownerSelectedRoomId = newRoomId
        : visitorSelectedRoomId = newRoomId;
    selectedRoomId = _ownerView == 1
        ? ownerSelectedRoomId
        : visitorSelectedRoomId;
    await loadRoom();
  }

  Future<bool> validateAndSelectRoom(String? id) async {
    if (id == null) return false;

    final myRooms = await fetchRooms();
    final isValidRoom = myRooms.any((room) => room.id.toString() == id);

    if (isValidRoom) {
      if (ownerView == 0) {
        visitorSelectedRoomId = id;
      } else {
        ownerSelectedRoomId = id;
      }
      selectedRoomId = id;
      notifyListeners();
      return true;
    } else {
      notify.showToast('Invalid room or access denied');
      return false;
    }
  }

  Future<bool> checkConnection() async {
    if (await helpers.handleIsInternetConnection()) return true;
    notify.showToast('Please connect to internet');
    return false;
  }

  RoomModel? get selectedRoom {
    if (rooms == null || rooms!.isEmpty || selectedRoomId == null) return null;
    try {
      return rooms!.firstWhere((r) => r.id.toString() == selectedRoomId);
    } catch (_) {
      return null;
    }
  }

  Future<void> init() async {
    String email = sm.email;
    await setOwnerView(0);
    isLoading = true;
    notifyListeners();
    if (!await checkConnection()) return;
    final room = selectedRoom;
    sm.checkIfValidToken();
    isOwner = await resolveUserRole(email);
    _visitReason = sm.visitReason;
    subscribedBlocks = await api.getMySubscriptions();
    final myRooms = await fetchRooms();
    if (myRooms.isEmpty) {
      noRoomsFound = true;
      isLoading = false;
      notifyListeners();
      return;
    }

    visitorSelectedRoomId = myRooms[0].id.toString();
    selectedRoomId = visitorSelectedRoomId;
    await refreshRoomData(myRooms[0].id);
    isLoading = false;
    notifyListeners();
  }

  Future<bool> resolveUserRole(String email) async {
    try {
      return await api.getRole() == "teacher";
    } catch (_) {
      notify.showToast('Error while acquiring role');
      return false;
    }
  }
}

enum ViewMode { visitor, owner }
