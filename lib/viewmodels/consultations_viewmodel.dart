import 'package:consultation_app/models/block_model.dart';
import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/models/slot_model.dart';
import 'package:consultation_app/models/user_model.dart';
import 'package:consultation_app/services/apiService.dart';
import 'package:consultation_app/utils/notifyUserUtils.dart';
import 'package:consultation_app/utils/helperFunctions.dart';

class ConsultationsViewmodel {
  NotifyUserUtils dialogs = NotifyUserUtils();
  HelperFunctions _helperFunctions = HelperFunctions();
  final ApiService _apiService = ApiService();
  List<UserModel>? users = [];
  List<RoomModel>? rooms = [];
  List<RoomModel>? allRooms = [];
  Map<int, List<SlotModel>?> slotsInBlocks = {};
  List<BlockModel> blocks = [];
  Future<void> fetchData(String token, int roomId) async {
    users = [];
    rooms = [];
    blocks = [];
    slotsInBlocks = {};
    users = await _apiService.getUsers(token);
    rooms = await _apiService.getMyRooms(token);

    if (rooms != null) {
      if (rooms!.isEmpty) {
        return;
      }
    }
    blocks = await _apiService.getBlocks(token, roomId);
    //to get slots parallel
    List<Future<void>> futures = [];
    for (var block in blocks) {
      futures.add(() async {
        final slots = await _apiService.getSlotsForBlock(block.id, token);
        if (slots != null) {
          slots.sort((a, b) {
            return _helperFunctions.compareTimeStringsDesc(
              a.startTime,
              b.startTime,
            );
          });
        }
        slotsInBlocks[block.id] = slots;
      }());
    }
    await Future.wait(futures);
  }

  Future<void> fetchAllRooms(String token) async {
    allRooms = await _apiService.getAllRooms(token);
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
          return _helperFunctions.getTDateOnlySimple(
            DateTime.parse(tmpBlock.date.toString()),
          );
        }
      }
    }
    return "";
  }

  Future<bool> isTeacher(String token, String email) async {
    try {
      String result = await _apiService.getRole(token, email);
      return result == "teacher" ? true : false;
    } catch (e) {
      dialogs.showToast('Error while acquiring role.');
      return false;
    }
  }
}
