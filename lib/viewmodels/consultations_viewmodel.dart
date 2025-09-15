import 'package:consultation_app/models/block_model.dart';
import 'package:consultation_app/models/slot_model.dart';
import 'package:consultation_app/models/user_model.dart';
import 'package:consultation_app/utils/dialogs.dart';
import 'package:consultation_app/utils/helper_functions.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConsultationsViewmodel {
  Dialogs dialogs = Dialogs();
  HelperFunctions _helperFunctions = HelperFunctions();
  List<UserModel>? users = [];
  Map<int, List<SlotModel>?> slotsInBlocks = {};
  List<BlockModel> blocks = [];
  Future<void> fetchData(String token, int roomId) async {
    users = await getUsers(token);
    blocks = await getBlocks(token, roomId);
   
    //to get slots parallel
    List<Future<void>> futures = [];
    for (var block in blocks) {
      futures.add(() async {
        if (block != null) {
          final slots = await getSlotsForBlock(block.id, token);
          slotsInBlocks[block.id] = slots;
        }
      }());
    }
    await Future.wait(futures);
  }

  Future<List<UserModel>> getUsers(String token) async {
    final Uri url = Uri.parse(
      'https://consultations-backend.onrender.com/users',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body);

      List<UserModel> users = decoded
          .map((json) => UserModel.fromJson(json))
          .toList();

      return users;
    } else {
      throw Exception('Failed to fetch users: ${response.statusCode}');
    }
  }

  Future<List<BlockModel>> getBlocks(String token, int roomId) async {
    final Uri url = Uri.parse(
      'https://consultations-backend.onrender.com/block/get?room_id=${roomId}',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      final List<dynamic> blocksJson = decoded['blocks'];
      List<BlockModel> blocksForRoom = blocksJson
          .map((json) => BlockModel.fromJson(json))
          .toList();

      return blocksForRoom;
    } else {
      throw Exception('Failed to fetch users: ${response.statusCode}');
    }
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

  Future<List<SlotModel>?> getSlotsForBlock(int blockId, String token) async {
    final Uri url = Uri.parse(
      'https://consultations-backend.onrender.com/slot/get?block_id=${blockId}',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      final List<dynamic> slotsJson = decoded['slots'];

      List<SlotModel>? slotsForBlock = slotsJson
          .map((json) => SlotModel.fromJson(json))
          .toList();

      return slotsForBlock;
    } else {
      throw Exception('Failed to fetch users: ${response.statusCode}');
    }
  }
}
