import 'package:consultation_app/models/block_model.dart';
import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/models/slot_model.dart';
import 'package:consultation_app/models/user_model.dart';
import 'package:consultation_app/setup.dart';
import 'package:flutter/foundation.dart';

class BaseConsultationsViewmodel extends ChangeNotifier {
  bool isTeacher = false;
  bool isLoading = false;
  Map<int, bool> _addingSlotBefore = {};
  Map<int, bool> _addingSlotAfter = {};

  bool isAddingSlotBefore(int blockId) => _addingSlotBefore[blockId] ?? false;
  bool isAddingSlotAfter(int blockId) => _addingSlotAfter[blockId] ?? false;
  bool blocksFiltered = false;
  bool noRoomsFound = false;
  //base atributes
  List<UserModel>? users = [];
  List<RoomModel>? rooms = [];
  Map<int, List<SlotModel>?> slotsInBlocks = {};
  List<BlockModel> blocks = [];
  Map<int, bool> blockNotificationEnabled = {};
  String? ownerSelectedRoomId;
  String? visitorSelectedRoomId;

  int _ownerView = 1;
  int get ownerView => _ownerView;
  String? selectedRoomId;

  //Slot

  Map<int, bool> _slotLoading = {};

  bool isSlotLoading(int slotId) => _slotLoading[slotId] ?? false;

  Map<int, bool> _optimisticallyReleased = {};

  bool isOptimisticallyReleased(int slotId) =>
      _optimisticallyReleased[slotId] ?? false;
  Map<int, bool> _takingSlot = {};

  bool isTakingSlot(int slotId) => _takingSlot[slotId] ?? false;
  // Move takeSlot logic here
  Future<void> takeSlot(String token, int slotId, String note,int isOnline) async {
    _takingSlot[slotId] = true;
    notifyListeners();
    try {
      await api.takeSlot(token, slotId, note,isOnline);
    } catch (e) {
      _takingSlot[slotId] = false;
      notify.showToast('manipulated');
      rethrow;
    } finally {
      _takingSlot.remove(slotId);
      loadRoom(token);
    }
  }

  // Move releaseSlot logic here
  Future<void> releaseSlot(String token, int slotId) async {
    _optimisticallyReleased[slotId] = true;
    notifyListeners();
    try {
      await api.releaseSlot(token, slotId);
    } catch (e) {
      _optimisticallyReleased[slotId] = false;
      notify.showToast('Failed to release slot.');
      rethrow;
    } finally {
      _optimisticallyReleased.remove(slotId);
      loadRoom(token);
    }
  }

  Future<void> onChangeConsultationType(String token, int slotId) async {
    isLoading = true;
    notifyListeners();
    try {
      await api.changeConsultationType(token, slotId);
    } catch (e) {
      notify.showToast('Slot cannot be manipulated.');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
      loadRoom(token);
    }
  }
  //blocks

  void handleEmailSubscribe(String token, int block) async {
    bool receiveEmails = await prefs.getItem('receiveEmails');
    if (receiveEmails == true) {
      api.subscribeToBlock(token, block);
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

  Future<List<RoomModel>> fetchRooms(String token) => api.getJoinedRooms(token);
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

  Future<void> loadRoom(String token) async {
    helpers.checkIfValidToken(token);
    if (roomIdNumber != null) {
      await refreshRoomData(token, roomIdNumber!);
    }
  }

  Future<void> refreshRoomData(String token, int roomId) async {
    if (!await checkConnection()) return;

    final newUsers = await api.getUsers(token);
    final newRooms = await fetchRooms(token);

    if (newRooms.isEmpty) {
      noRoomsFound = true;
      notifyListeners();
      return;
    }

    noRoomsFound = false;
    List<BlockModel> newBlocks = await api.getBlocks(token, roomId);

    DateTime now = DateTime.now();
    newBlocks.removeWhere((b) => !b.date.isAfter(now));
    newBlocks.sort((a, b) => a.date.compareTo(b.date));

    Map<int, List<SlotModel>?> newSlotsInBlocks = {};
    List<Future<void>> futures = [];
    for (var block in newBlocks) {
      //TODO blockNotificationEnabled[block.id]=api.get   api.get-my-subscribtions;
      futures.add(() async {
        final slots = await api.getSlotsForBlock(block.id, token);
        if (slots != null) {
          slots.sort((a, b) => a.startTime.compareTo(b.startTime));
          newSlotsInBlocks[block.id] = slots;
        } else {
          newSlotsInBlocks[block.id] = [];
        }
      }());
    }
    await Future.wait(futures);

    users = newUsers;
    rooms = newRooms;
    blocks = newBlocks;
    slotsInBlocks = newSlotsInBlocks;
    blocksFiltered = true;
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

  //Student functionalities
  Future<void> switchRoom(String newRoomId) async {
    _ownerView == 1
        ? ownerSelectedRoomId = newRoomId
        : visitorSelectedRoomId = newRoomId;
    selectedRoomId = _ownerView == 1
        ? ownerSelectedRoomId
        : visitorSelectedRoomId;
    await loadRoom(await prefs.getItem("token"));
  }

  Future<bool> validateAndSelectRoom(String? id) async {
    if (id == null) return false;

    final myRooms = await fetchRooms(await prefs.getItem('token'));
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
      notify.showToast('Invalid room or access denied.');
      return false;
    }
  }

  Future<bool> checkConnection() async {
    if (await helpers.handleIsInternetConnection()) return true;
    notify.showToast('Please connect to internet.');
    return false;
  }

  // base_consultations_viewmodel.dart
  Future<void> init(String token, String email) async {
    await setOwnerView(0);
    isLoading = true;
    notifyListeners();
    if (!await checkConnection()) return;

    helpers.checkIfValidToken(token);
    isTeacher = await resolveUserRole(token, email);

    final myRooms = await fetchRooms(token);
    if (myRooms.isEmpty) {
      noRoomsFound = true;
      isLoading = false;
      notifyListeners();
      return;
    }

    visitorSelectedRoomId = myRooms[0].id.toString();
    selectedRoomId = visitorSelectedRoomId;
    await refreshRoomData(token, myRooms[0].id);
    isLoading = false;
    notifyListeners();
  }

  Future<bool> resolveUserRole(String token, String email) async {
    try {
      return await api.getRole(token, email) == "teacher";
    } catch (_) {
      notify.showToast('Error while acquiring role.');
      return false;
    }
  }
}

enum ViewMode { visitor, owner }
