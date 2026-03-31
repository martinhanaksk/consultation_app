import 'dart:convert';
import 'package:consultation_app/setup.dart';
import 'package:http/http.dart' as http;
import 'package:consultation_app/models/user_model.dart';
import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/models/block_model.dart';
import 'package:consultation_app/models/slot_model.dart';

class ApiService {
  //verify
  Future<bool> connect(String email, String otp, bool rememberMe) async {
    final Uri url = getVerifyLoginOtpUrl(rememberMe);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      await prefs.saveItem('email', email);
      await prefs.saveItem('token', data['token']);
      await prefs.saveItem('role', data['role']);
      if ((await prefs.getItem('receiveEmails') == "")) {
        await prefs.saveItem('receiveEmails', false);
      }

      return true;
    } else {
      return false;
    }
  }

  Future<http.Response> requestLoginOtp(String email) async {
    return await http.post(
      Uri.parse('${constants.url}/auth/request-login-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
  }

  Uri getVerifyLoginOtpUrl(bool rememberMe) {
    if (rememberMe) {
      return Uri.parse('${constants.url}/auth/verify-login-otp-long');
    }
    return Uri.parse('${constants.url}/auth/verify-login-otp');
  }

  //register
  Future<String> registerUser(UserModel um) async {
    final Uri url = Uri.parse('${constants.url}/users/register');

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

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      await prefs.saveItem('email', um.email);
      await prefs.saveItem('token', data['token']);
      await prefs.saveItem('role', data['role']);
      return data['token'];
    } else {
      return '';
    }
  }

  Future<void> joinRoomById(String token, int id) async {
    if (id != null) {
      final Uri url = Uri.parse('${constants.url}/room/join?room_id=$id');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to join room: ${response.statusCode}');
      }
    }
  }

  //consultations
  Future<List<UserModel>> getUsers(String token) async {
    final Uri url = Uri.parse('${constants.url}/users');

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
      nav.toLogin();
      throw Exception('Failed to fetch users: ${response.statusCode}');
    }
  }

  //consultations
  Future<UserModel> getUserByEmail(String token, String email) async {
    final Uri url = Uri.parse('${constants.url}/users?email=$email');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      return UserModel.fromJson(decoded);
    } else {
      nav.toLogin();
      throw Exception('Failed to fetch users: ${response.statusCode}');
    }
  }

  Future<List<RoomModel>> getAllRooms(String token) async {
    final Uri url = Uri.parse('${constants.url}/room/get');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body);
      return decoded.map((json) => RoomModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch rooms: ${response.body}');
    }
  }

  Future<List<RoomModel>> getJoinedRooms(String token) async {
    final Uri urlToGetRooms = Uri.parse('${constants.url}/users/my-rooms');
    final responseToGetRooms = await http.get(
      urlToGetRooms,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    List<int> roomIds = [];
    if (responseToGetRooms.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(responseToGetRooms.body);
      roomIds = jsonList.map((json) => json['room_id'] as int).toList();
    } else {
      return [];
    }

    final List<RoomModel> allRooms = await getAllRooms(token);

    return allRooms.where((room) => roomIds.contains(room.id)).toList();
  }

  Future<List<RoomModel>> getMyRoomsTeacher(String token) async {
    final Uri urlToGetRooms = Uri.parse('${constants.url}/room/get-my');
    final responseToGetRooms = await http.get(
      urlToGetRooms,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    List<int> roomIds = [];
    if (responseToGetRooms.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(responseToGetRooms.body);
      roomIds = jsonList.map((json) => json['id'] as int).toList();
    } else {
      return [];
    }

    final List<RoomModel> allRooms = await getAllRooms(token);

    return allRooms.where((room) => roomIds.contains(room.id)).toList();
  }

  Future<List<BlockModel>> getBlocks(String token, int roomId) async {
    final Uri url = Uri.parse('${constants.url}/block/get?room_id=$roomId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body);

      return decoded.map((json) => BlockModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch blocks: ${response.statusCode}');
    }
  }

  //TODO http://office-hours.fit.vutbr.cz:8000/slot/get?id=1&option=True optional
  Future<List<SlotModel>?> getSlotsForBlock(int blockId, String token) async {
    final Uri url = Uri.parse('${constants.url}/slot/get?id=$blockId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body);
      return decoded.map((json) => SlotModel.fromJson(json)).toList();
    } else {
      return null;
    }
  }

  //slot
  Future<void> takeSlot(String token, int id, String note) async {
    final Uri url = Uri.parse(
      '${constants.url}/slot/take?slot_id=$id&note=$note',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      //TODO
      //throw Exception('Failed to take slot: ${response.statusCode}');
    }
  }

  Future<void> releaseSlot(String token, int id) async {
    final Uri url = Uri.parse('${constants.url}/slot/release?slot_id=$id');

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

  Future<void> subscribeToBlock(String token, int blockid) async {
    final Uri url = Uri.parse(
      '${constants.url}/block/subscribe?block_id=$blockid',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to subscribe to block: ${response.statusCode}');
    }
  }

  Future<String> getRole(String token, String email) async {
    final Uri url = Uri.parse('${constants.url}/users?email=$email');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data != null) {
        if (data['role'] != null) {
          return data['role'].toString();
        } else {
          return 'student';
        }
      } else {
        return 'student';
      }
    } else {
      throw Exception('Failed to fetch role: ${response.statusCode}');
    }
  }

  //teacher methods
  Future<bool> createRoom(
    String token,
    String roomName,
    String title,
    String description,
    List<String> acceptedEmailsArray,
  ) async {
    String convertedAcceptedEmails = helpers.acceptedEmailsFormater(
      acceptedEmailsArray,
    );
    final Uri url = Uri.parse('${constants.url}/room/create');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "shortname": roomName,
        "title": title,
        "description": description,
        "accepted_emails": convertedAcceptedEmails,
      }),
    );
    if (response.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future<String> createBlock(String token, int id, String date) async {
    final Uri url = Uri.parse('${constants.url}/block/create');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({"room_id": id, "date": date}),
    );
    if (response.statusCode != 200) {
      notify.showToast("Failed to create block");
      return "";
    } else {
      return response.body;
    }
  }

  Future<bool> createSlot(
    String token,
    int block_id,
    String start_time,
    int duration,
    int is_online,
    String note,
  ) async {
    final Uri url = Uri.parse('${constants.url}/slot/create');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "block_id": block_id,
        "slots": [
          {
            "start_time": start_time,
            "duration": duration,
            "is_online": is_online,
            "note": note,
          },
        ],
      }),
    );
    if (response.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> deleteRoom(String token, int roomid) async {
    final Uri url = Uri.parse('${constants.url}/room/delete?room_id=$roomid');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }
  Future<bool> deleteBlock(String token, int blockId) async {
    final Uri url = Uri.parse('${constants.url}/block/delete?block_id=$blockId');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> getIsTeacher() async {
    String? role = await prefs.getItem('role');
    if (role == 'teacher') {
      return true;
    }
    return false;
  }
}
