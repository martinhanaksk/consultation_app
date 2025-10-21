import 'dart:convert';
import 'package:consultation_app/services/user_preferences.dart';
import 'package:consultation_app/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:consultation_app/models/user_model.dart';
import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/models/block_model.dart';
import 'package:consultation_app/models/slot_model.dart';

class ApiService {
    Constants _constants = Constants();

  //verify
  Future<String> connect(String email, String otp) async {
    final Uri url = Uri.parse('${_constants.url}/auth/verify-login-otp');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );
   await UserPreferences.saveUser(email, true);
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data['token'];
    } else {
      return '';
    }
  }

  //register
  Future<String> registerUser(UserModel um) async {
    final Uri url = Uri.parse('${_constants.url}/users/register?email=${um.email}');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": um.email,
        "name": um.name,
        "surname": um.surname,
        "visit_reason": um.visitReason,
      }),
    );
    await UserPreferences.saveUser(um.email, true);
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data['token'];
    } else {
      return '';
    }
  }

  //consultations
  Future<List<UserModel>> getUsers(String token) async {
    final Uri url = Uri.parse('${_constants.url}/users');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body);
      return decoded.map((json) => UserModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch users: ${response.statusCode}');
    }
  }

  Future<List<RoomModel>> getRooms(String token) async {
    final Uri url = Uri.parse('${_constants.url}/room/get');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      final List<dynamic> roomsJson = decoded['rooms'];
      return roomsJson.map((json) => RoomModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch rooms: ${response.statusCode}');
    }
  }

  Future<List<BlockModel>> getBlocks(String token, int roomId) async {
    final Uri url = Uri.parse('${_constants.url}/block/get?room_id=$roomId');

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
      return blocksJson.map((json) => BlockModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch blocks: ${response.statusCode}');
    }
  }

  Future<List<SlotModel>?> getSlotsForBlock(int blockId, String token) async {
    final Uri url = Uri.parse('${_constants.url}/slot/get?block_id=$blockId');

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
      return slotsJson.map((json) => SlotModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch slots: ${response.statusCode}');
    }
  }
  
  //slot
  Future<void> takeSlot(String token, int id, String note) async {
    final Uri url = Uri.parse('${_constants.url}/slot/take?slot_id=$id&note=$note');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to take slot: ${response.statusCode}');
    }
  }

  Future<void> releaseSlot(String token, int id) async {
    final Uri url = Uri.parse('${_constants.url}/slot/release?slot_id=$id');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to release slot: ${response.statusCode}');
    }
  }
}
