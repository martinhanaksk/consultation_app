import 'package:consultation_app/models/block_model.dart';
import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/models/slot_model.dart';
import 'package:consultation_app/models/user_model.dart';
import 'package:consultation_app/setup.dart';
import 'package:flutter/foundation.dart';

abstract class BaseConsultationsViewmodel extends ChangeNotifier {
  List<UserModel>? users = [];
  List<RoomModel>? rooms = [];
  Map<int, List<SlotModel>?> slotsInBlocks = {};
  List<BlockModel> blocks = [];
  bool blocksFiltered = false;
  String? selectedRoomId;
  bool hasNoRooms = false;

  int foundBlocksLength() {
    if (blocksFiltered && blocks.isNotEmpty) {
      return blocks.length;
    }
    return 0;
  }

  Future<void> loadRoom(String token, int roomId) async {
    if (!await helpers.handleIsInternetConnection()) {
      notify.showToast('Please connect to internet.');
      return;
    }

    helpers.checkIfValidToken(token);
    selectedRoomId = roomId.toString();
    await fetchData(token, roomId);
    notifyListeners();
  }

  Future<void> fetchData(String token, int roomId) async {
    if (!await helpers.handleIsInternetConnection()) {
      notify.showToast('Please connect to internet.');
      return;
    }

    users = [];
    rooms = [];
    blocks = [];
    slotsInBlocks = {};

    users = await api.getUsers(token);
    rooms = await api.getMyRooms(token);

    if (rooms == null || rooms!.isEmpty) {
      hasNoRooms = true;
      notifyListeners();
      return;
    }

    hasNoRooms = false;
    blocks = await api.getBlocks(token, roomId);

    DateTime now = DateTime.now();
    blocks.removeWhere((b) => !b.date.isAfter(now));

    blocks.sort((a, b) => a.date.compareTo(b.date));
    blocksFiltered = true;

    List<Future<void>> futures = [];
    for (var block in blocks) {
      futures.add(() async {
        final slots = await api.getSlotsForBlock(block.id, token);
        if (slots != null) {
          slots.sort((a, b) => a.startTime.compareTo(b.startTime));
        }
        slotsInBlocks[block.id] = slots;
      }());
    }
    await Future.wait(futures);

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

  String getDateOfBlock(int blockId) {
    for (var tmpBlock in blocks) {
      if (tmpBlock.id == blockId) {
        return helpers.getTDateOnlySimple(
              DateTime.parse(tmpBlock.date.toString()),
            ) +
            " " +
            getDaysRemainingTillDate(tmpBlock.date);
      }
    }
    return "";
  }

  String getDaysRemainingTillDate(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    final diff = target.difference(today).inDays;
    if (diff < 0) return "";
    if (diff == 0) return "(today)";
    if (diff == 1) return "(tomorrow)";

    return "($diff d.)";
  }
}
