import 'package:consultation_app/models/block_model.dart';
import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/models/slot_model.dart';
import 'package:consultation_app/models/user_model.dart';
import 'package:consultation_app/services/api_service.dart';
import 'package:consultation_app/setup.dart';
import 'package:consultation_app/utils/notify_user_utils.dart';
import 'package:consultation_app/utils/helper_functions.dart';

class ConsultationsViewmodel {
  List<UserModel>? users = [];
  List<RoomModel>? rooms = [];
  List<RoomModel>? allRooms = [];
  Map<int, List<SlotModel>?> slotsInBlocks = {};
  List<BlockModel> blocks = [];
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
      blocks.sort((a, b) {
        return a.date.compareTo(b.date);
      });
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

  Future<void> fetchAllRooms(String token) async {
    allRooms = await api.getAllRooms(token);
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
