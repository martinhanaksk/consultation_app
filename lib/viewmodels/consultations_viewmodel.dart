import 'package:consultation_app/models/block_model.dart';
import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/models/slot_model.dart';
import 'package:consultation_app/models/user_model.dart';
import 'package:consultation_app/setup.dart';
import 'package:flutter/foundation.dart';

class ConsultationsViewmodel  extends ChangeNotifier {
  List<UserModel>? users = [];
  List<RoomModel>? rooms = [];
  Map<int, List<SlotModel>?> slotsInBlocks = {};
  List<BlockModel> blocks = [];
  bool blocksFiltered = false;
  int foundBlocksLength() {
    if (blocksFiltered && blocks.isNotEmpty) {
      return blocks.length;
    }
    return 0;
  }

  Future<void> fetchData(String token, int roomId) async {
    bool connected = await helpers.handleIsInternetConnection();
    if (!connected) {
      notify.showToast('Please connect to internet.');
    } else {
      users = [];
      rooms = [];
      blocks = [];
      slotsInBlocks = {};
      users = await api.getUsers(token);
      rooms = await api.getMyRooms(token);

      if (rooms != null) {
        if (rooms!.isEmpty) {
          return;
        }
      }
      blocks = await api.getBlocks(token, roomId);

      DateTime now = DateTime.now();
      bool removedItem = true;
      while (removedItem) {
        removedItem = false;
        for (int i = 0; i < blocks.length; i++) {
          if (!blocks[i].date.isAfter(now)) {
            removedItem = true;
            blocks.remove(blocks[i]);
          }
        }
      }
      blocks.sort((a, b) => a.date.compareTo(b.date));
      blocksFiltered = true;

      //to get slots parallel
      List<Future<void>> futures = [];
      for (var block in blocks) {
        futures.add(() async {
          final slots = await api.getSlotsForBlock(block.id, token);
          if (slots != null) {
            slots.sort((a, b) {
              return a.startTime.compareTo(b.startTime);
            });
          }
          slotsInBlocks[block.id] = slots;
        }());
      }
      await Future.wait(futures);
    }
  }

 

  UserModel? getUserByEmail(String emailToFind) {
    if (users != null) {
      for (var tmpUser in users!) {
        if (tmpUser.email == emailToFind) {
          return tmpUser;
        } else {}
      }
    }
    return null;
  }

  String getDateOfBlock(int blockid) {
    if (blocks != null) {
      for (var tmpBlock in blocks!) {
        if (tmpBlock.id == blockid) {
          return helpers.getTDateOnlySimple(
            DateTime.parse(tmpBlock.date.toString()),
          );
        }
      }
    }
    return "";
  }

  Future<bool> isTeacher(String token, String email) async {
    try {
      String result = await api.getRole(token, email);
      return result == "teacher" ? true : false;
    } catch (e) {
      notify.showToast('Error while acquiring role.');
      return false;
    }
  }
}
