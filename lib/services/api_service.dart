import 'dart:convert';
import 'package:consultation_app/setup.dart';
import 'package:http/http.dart' as http;
import 'package:consultation_app/models/user_model.dart';
import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/models/block_model.dart';
import 'package:consultation_app/models/slot_model.dart';

class ApiService {
  // ==========================================
  // HELPERS
  // ==========================================

  Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  void _checkUnauthorized(http.Response response) {
    if (response.statusCode == 401) {
      nav.toLogin();
      throw Exception('Token has expired. Please log in again.');
    }
  }

  // ==========================================
  // 1. AUTHENTICATION & SESSION
  // ==========================================

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
      await securePrefs.saveToken(data['token']);
      await prefs.saveItem('role', data['role']);
      if ((await prefs.getItem('receiveEmails') == "")) {
        await prefs.saveItem('receiveEmails', false);
      }
      bool visibilityResponse = await getVisibility(data['token'], email);
      await prefs.saveItem('visibility', visibilityResponse);

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

  Future<http.Response> registerUser(UserModel um) async {
    final Uri url = Uri.parse('${constants.url}/auth/register');

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

    if (response.statusCode == 200) {
      await prefs.saveItem('email', um.email);
    }
    return response;
  }

  Future<String> getRole(String token, String email) async {
    final Uri url = Uri.parse('${constants.url}/users?email=$email');
    final response = await http.get(url, headers: _headers(token));

    _checkUnauthorized(response);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data != null && data['role'] != null) {
        return data['role'].toString();
      }
      return 'student';
    } else {
      throw Exception('Failed to fetch role: ${response.statusCode}');
    }
  }

  Future<bool> getIsOwner() async {
    String? role = await prefs.getItem('role');
    return role == 'teacher';
  }

  // ==========================================
  // 2. USERS & VISIBILITY
  // ==========================================
  Future<void> updateUserData(
    String token,
    String name,
    String surname,
    String visitReason,
    bool visible,
    int notificationHoursBefore,
  ) async {
    final Uri url = Uri.parse('${constants.url}/users/data');

    final response = await http.post(
      url,
      headers: _headers(token),
      body: jsonEncode({
        "name": name,
        "surname": surname,
        "visit_reason": visitReason,
        "visible": visible,
        "notification": notificationHoursBefore,
      }),
    );

    _checkUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception('Failed to update user data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getUserData(String token, String email) async {
    final Uri url = Uri.parse('${constants.url}/users/data?email=$email');
    final response = await http.get(url, headers: _headers(token));

    _checkUnauthorized(response);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch user data: ${response.statusCode}');
    }
  }

  Future<List<UserModel>> getUsers(String token) async {
    final Uri url = Uri.parse('${constants.url}/users');
    final response = await http.get(url, headers: _headers(token));

    _checkUnauthorized(response);

    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body);
      return decoded.map((json) => UserModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch users: ${response.statusCode}');
    }
  }

  Future<UserModel> getUserByEmail(String token, String email) async {
    final Uri url = Uri.parse('${constants.url}/users?email=$email');
    final response = await http.get(url, headers: _headers(token));

    _checkUnauthorized(response);

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      return UserModel.fromJson(decoded);
    } else {
      throw Exception('Failed to fetch users: ${response.statusCode}');
    }
  }

  Future<bool> createTeacher(
    String token,
    String email,
    String name,
    String surname,
  ) async {
    final Uri url = Uri.parse(
      '${constants.url}/users/create-teacher?email=$email&name=$name&surname=$surname',
    );
    final response = await http.post(url, headers: _headers(token));

    _checkUnauthorized(response);
    print(response.body);
    return response.statusCode == 200;
  }

  Future<bool> getVisibility(String token, String email) async {
    final Uri url = Uri.parse('${constants.url}/users/visible?email=$email');
    final response = await http.get(url, headers: _headers(token));

    _checkUnauthorized(response);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data != null ? (data['visible'] ?? false) : false;
    }
    throw Exception('Failed to get visibility ${response.statusCode}');
  }

  Future<void> setVisibility(String token) async {
    final Uri url = Uri.parse('${constants.url}/users/visible');
    final response = await http.post(url, headers: _headers(token));

    _checkUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception('Failed to set visibility ${response.statusCode}');
    }
  }

  // ==========================================
  // 3. ROOMS
  // ==========================================

  Future<List<RoomModel>> getAllRooms(String token) async {
    final Uri url = Uri.parse('${constants.url}/room/get');
    final response = await http.get(url, headers: _headers(token));

    _checkUnauthorized(response);

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
      headers: _headers(token),
    );

    _checkUnauthorized(responseToGetRooms);

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

  Future<List<RoomModel>> getMyRoomsOwner(String token) async {
    final Uri urlToGetRooms = Uri.parse('${constants.url}/room/get-my');
    final responseToGetRooms = await http.get(
      urlToGetRooms,
      headers: _headers(token),
    );

    _checkUnauthorized(responseToGetRooms);

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

  Future<void> joinRoomById(String token, int id) async {
    final Uri url = Uri.parse('${constants.url}/room/join?room_id=$id');
    final response = await http.post(url, headers: _headers(token));

    _checkUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception('Failed to join room: ${response.statusCode}');
    }
  }

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
      headers: _headers(token),
      body: jsonEncode({
        "shortname": roomName,
        "title": title,
        "description": description,
        "accepted_emails": convertedAcceptedEmails,
      }),
    );

    _checkUnauthorized(response);
    return response.statusCode == 200;
  }

  Future<bool> editRoom(
    String token,
    int roomId,
    String shortName,
    String title,
    String description,
    List<String> acceptedEmailsArray,
  ) async {
    String convertedAcceptedEmails = helpers.acceptedEmailsFormater(
      acceptedEmailsArray,
    );
    final Uri url = Uri.parse('${constants.url}/room/edit?room_id=$roomId');

    final response = await http.post(
      url,
      headers: _headers(token),
      body: jsonEncode({
        "shortname": shortName,
        "title": title,
        "description": description,
        "accepted_emails": convertedAcceptedEmails,
      }),
    );

    _checkUnauthorized(response);
    return response.statusCode == 200;
  }

  Future<bool> deleteRoom(String token, int roomid) async {
    final Uri url = Uri.parse('${constants.url}/room/delete?room_id=$roomid');
    final response = await http.delete(url, headers: _headers(token));

    _checkUnauthorized(response);
    return response.statusCode == 200;
  }

  Future<List<String>> getConnectedUsersInRoom(String token, int roomId) async {
    final Uri url = Uri.parse(
      '${constants.url}/room/get-conected-users?room_id=$roomId',
    );
    final response = await http.get(url, headers: _headers(token));

    _checkUnauthorized(response);

    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body);
      return decoded.map((json) => json['user_email'] as String).toList();
    } else {
      throw Exception(
        'Failed to fetch connected users: ${response.statusCode}',
      );
    }
  }

  // ==========================================
  // 4. BLOCKS & SUBSCRIPTIONS
  // ==========================================

  Future<List<BlockModel>> getBlocks(String token, int roomId) async {
    final Uri url = Uri.parse('${constants.url}/block/get?room_id=$roomId');
    final response = await http.get(url, headers: _headers(token));

    _checkUnauthorized(response);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is! List) return [];
      return decoded.map((json) => BlockModel.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  Future<String> createBlock(String token, int id, String date) async {
    final Uri url = Uri.parse('${constants.url}/block/create');
    final response = await http.post(
      url,
      headers: _headers(token),
      body: jsonEncode({"room_id": id, "date": date}),
    );

    _checkUnauthorized(response);

    if (response.statusCode != 200) {
      notify.showToast("Failed to create block");
      return "";
    } else {
      return response.body;
    }
  }

  Future<bool> deleteBlock(String token, int blockId) async {
    final Uri url = Uri.parse(
      '${constants.url}/block/delete?block_id=$blockId',
    );
    final response = await http.delete(url, headers: _headers(token));

    _checkUnauthorized(response);
    return response.statusCode == 200;
  }

  Future<void> setBlockOffline(String token, int blockId) async {
    final Uri url = Uri.parse(
      '${constants.url}/block/set-offline?block_id=$blockId',
    );
    final response = await http.post(url, headers: _headers(token));

    _checkUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception('Failed to set block offline ${response.statusCode}');
    }
  }

  Future<void> setBlockOnline(String token, int blockId) async {
    final Uri url = Uri.parse(
      '${constants.url}/block/set-online?block_id=$blockId',
    );
    final response = await http.post(url, headers: _headers(token));

    _checkUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception('Failed to set block online ${response.statusCode}');
    }
  }

  Future<void> subscribeToBlock(String token, int blockId) async {
    final Uri url = Uri.parse(
      '${constants.url}/block/subscribe?block_id=$blockId',
    );
    final response = await http.post(url, headers: _headers(token));

    _checkUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception('Failed to subscribe to block: ${response.statusCode}');
    }
  }

  Future<List<int>> getMySubscriptions(String token) async {
    final Uri url = Uri.parse('${constants.url}/block/get-my-subscriptions');
    final response = await http.get(url, headers: _headers(token));

    _checkUnauthorized(response);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return List<int>.from(decoded.map((json) => json['block_id'] as int));
    } else {
      throw Exception('Failed to get subscriptions: ${response.statusCode}');
    }
  }

  // ==========================================
  // 5. SLOTS
  // ==========================================

  Future<List<SlotModel>?> getSlotsForBlock(String token, int blockId) async {
    final Uri url = Uri.parse('${constants.url}/slot/get?id=$blockId');
    final response = await http.get(url, headers: _headers(token));

    _checkUnauthorized(response);

    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body);
      return decoded.map((json) => SlotModel.fromJson(json)).toList();
    } else {
      return null;
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
      headers: _headers(token),
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

    _checkUnauthorized(response);
    return response.statusCode == 200;
  }

  Future<void> takeSlot(
    String token,
    int id,
    String note,
    int is_online,
  ) async {
    final Uri url = Uri.parse(
      '${constants.url}/slot/take?slot_id=$id&note=$note&is_online=$is_online',
    );
    final response = await http.post(url, headers: _headers(token));

    _checkUnauthorized(response);

    if (response.statusCode != 200) {
      notify.showToast("'Failed to take slot");
    }
  }

  Future<void> releaseSlot(String token, int id) async {
    final Uri url = Uri.parse('${constants.url}/slot/release?slot_id=$id');
    final response = await http.post(url, headers: _headers(token));

    _checkUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception('Failed to release slot: ${response.statusCode}');
    }
  }

  Future<bool> deleteSlot(String token, int slotId) async {
    final Uri url = Uri.parse('${constants.url}/slot/delete?slot_id=$slotId');
    final response = await http.delete(url, headers: _headers(token));

    _checkUnauthorized(response);
    return response.statusCode == 200;
  }

  Future<void> changeConsultationType(String token, int slot_id) async {
    final Uri url = Uri.parse(
      '${constants.url}/slot/change-consultation-type?slot_id=$slot_id',
    );
    final response = await http.post(url, headers: _headers(token));

    _checkUnauthorized(response);

    if (response.statusCode != 200) {
      notify.showToast("Failed to change consultation type");
    }
  }
}
