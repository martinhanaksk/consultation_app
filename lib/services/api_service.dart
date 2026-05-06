// api_service.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Central HTTP client for all API communication.
// Organises endpoints into sections: auth, users, rooms, blocks, and slots.

import 'dart:convert';
import 'package:consultation_app/setup.dart';
import 'package:http/http.dart' as http;
import 'package:consultation_app/models/user_model.dart';
import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/models/block_model.dart';
import 'package:consultation_app/models/slot_model.dart';

class ApiService {
  // --- Shared helpers ---

  Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Redirects to login and notifies the user when the server rejects the token
  void _checkUnauthorized(http.Response response) {
    if (response.statusCode == 401) {
      nav.toLogin();
      notify.showToast('You were logged out');
    }
  }

  // --- Authentication ---

  // Verifies the OTP, fetches the user profile, and persists the session.
  // Returns true on success; false if the OTP is invalid or expired.
  Future<bool> connect(String email, String otp, bool rememberMe) async {
    final Uri url = getVerifyLoginOtpUrl(rememberMe);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final userDataFetched = await api.getUserData(data['token'], email);
      await sm.saveSession(
        data['token'],
        email,
        userDataFetched['role'],
        userDataFetched['visible'] == 1 ? true : false,
        userDataFetched['visit_reason'],
        userDataFetched['notification'],
        userDataFetched['name'],
        userDataFetched['surname'],
      );
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

  // Long-session endpoint keeps the token alive longer (based on API)
  Uri getVerifyLoginOtpUrl(bool rememberMe) {
    if (rememberMe) {
      return Uri.parse('${constants.url}/auth/verify-login-otp-long');
    }
    return Uri.parse('${constants.url}/auth/verify-login-otp');
  }

  // Registers a new user and immediately syncs the relevant fields into the session
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
      sm.updateEmail(um.email);
      sm.updateFullName(um.name, um.surname);
      sm.updateVisitReason(um.visitReason);
    }
    return response;
  }

  // --- Users ---

  // Falls back to 'student' if the API returns a null or missing role field
  Future<String> getRole() async {
    final Uri url = Uri.parse('${constants.url}/users?email=${sm.email}');
    final response = await http.get(url, headers: _headers(sm.token));

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

  // Resolved locally from the cached session — no network call needed
  Future<bool> getIsOwner() async {
    return sm.role == 'teacher';
  }

  // Updates both the server record and the local session cache in one call
  Future<void> updateUserData(
    String name,
    String surname,
    String visitReason,
    bool visible,
    int notificationHoursBefore,
  ) async {
    final Uri url = Uri.parse('${constants.url}/users/data');

    final response = await http.post(
      url,
      headers: _headers(sm.token),
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
    } else {
      sm.updateFullName(name, surname);
      sm.updateNotifyHoursBefore(notificationHoursBefore);
      sm.updateVisibility(visible);
      sm.updateVisitReason(visitReason);
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

  Future<List<UserModel>> getUsers() async {
    final Uri url = Uri.parse('${constants.url}/users');
    final response = await http.get(url, headers: _headers(sm.token));

    _checkUnauthorized(response);

    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body);
      return decoded.map((json) => UserModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch users: ${response.statusCode}');
    }
  }

  Future<UserModel> getUserByEmail(String email) async {
    final Uri url = Uri.parse('${constants.url}/users?email=$email');
    final response = await http.get(url, headers: _headers(sm.token));

    _checkUnauthorized(response);

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      return UserModel.fromJson(decoded);
    } else {
      throw Exception('Failed to fetch users: ${response.statusCode}');
    }
  }

  Future<bool> createTeacher(String email, String name, String surname) async {
    final Uri url = Uri.parse(
      '${constants.url}/users/create-teacher?email=$email&name=$name&surname=$surname',
    );
    final response = await http.post(url, headers: _headers(sm.token));

    _checkUnauthorized(response);

    return response.statusCode == 200;
  }

  Future<bool> getVisibility(String email) async {
    final Uri url = Uri.parse('${constants.url}/users/visible?email=$email');
    final response = await http.get(url, headers: _headers(sm.token));

    _checkUnauthorized(response);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data != null ? (data['visible'] ?? false) : false;
    }
    throw Exception('Failed to get visibility ${response.statusCode}');
  }

  // Toggles the current user's visibility — the server flips the state server-side
  Future<void> setVisibility() async {
    final Uri url = Uri.parse('${constants.url}/users/visible');
    final response = await http.post(url, headers: _headers(sm.token));

    _checkUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception('Failed to set visibility ${response.statusCode}');
    }
  }

  // --- Rooms ---

  Future<List<RoomModel>> getAllRooms() async {
    final Uri url = Uri.parse('${constants.url}/room/get');
    final response = await http.get(url, headers: _headers(sm.token));

    _checkUnauthorized(response);

    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body);
      return decoded.map((json) => RoomModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch rooms: ${response.body}');
    }
  }

  // Fetches the IDs of rooms the student has joined, then filters the full room list.
  // Two requests are made because the joined-rooms endpoint returns IDs only.
  Future<List<RoomModel>> getJoinedRooms() async {
    final Uri urlToGetRooms = Uri.parse('${constants.url}/users/my-rooms');
    final responseToGetRooms = await http.get(
      urlToGetRooms,
      headers: _headers(sm.token),
    );

    _checkUnauthorized(responseToGetRooms);

    List<int> roomIds = [];
    if (responseToGetRooms.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(responseToGetRooms.body);
      roomIds = jsonList.map((json) => json['room_id'] as int).toList();
    } else {
      return [];
    }

    final List<RoomModel> allRooms = await getAllRooms();
    return allRooms.where((room) => roomIds.contains(room.id)).toList();
  }

  // Same two-request pattern as getJoinedRooms, but scoped to rooms the teacher owns
  Future<List<RoomModel>> getMyRoomsOwner() async {
    final Uri urlToGetRooms = Uri.parse('${constants.url}/room/get-my');
    final responseToGetRooms = await http.get(
      urlToGetRooms,
      headers: _headers(sm.token),
    );

    _checkUnauthorized(responseToGetRooms);

    List<int> roomIds = [];
    if (responseToGetRooms.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(responseToGetRooms.body);
      roomIds = jsonList.map((json) => json['id'] as int).toList();
    } else {
      return [];
    }

    final List<RoomModel> allRooms = await getAllRooms();
    return allRooms.where((room) => roomIds.contains(room.id)).toList();
  }

  Future<void> joinRoomById(int id) async {
    final Uri url = Uri.parse('${constants.url}/room/join?room_id=$id');
    final response = await http.post(url, headers: _headers(sm.token));

    _checkUnauthorized(response);
    if (response.statusCode == 403) {
      // 403 means the student's email is not in the room's acceptedEmails list
      throw Exception('You cannot join this room');
    } else if (response.statusCode == 200) {
      notify.showToast('Room joined');
    } else {
      throw Exception('Failed to join room: ${response.statusCode}');
    }
  }

  // acceptedEmailsArray is converted to the comma-separated string the API expects
  Future<bool> createRoom(
    String roomName,
    String title,
    String description,
    int cancellationHours,
    List<String> acceptedEmailsArray,
  ) async {
    String convertedAcceptedEmails = helpers.acceptedEmailsFormater(
      acceptedEmailsArray,
    );
    final Uri url = Uri.parse('${constants.url}/room/create');

    final response = await http.post(
      url,
      headers: _headers(sm.token),
      body: jsonEncode({
        "link": roomName,
        "title": title,
        "description": description,
        "accepted_emails": convertedAcceptedEmails,
        "cancellation_notice_hours": cancellationHours,
      }),
    );

    _checkUnauthorized(response);
    return response.statusCode == 200;
  }

  Future<bool> editRoom(
    int roomId,
    String link,
    String title,
    String description,
    int cancellationHours,
    List<String> acceptedEmailsArray,
  ) async {
    String convertedAcceptedEmails = helpers.acceptedEmailsFormater(
      acceptedEmailsArray,
    );
    final Uri url = Uri.parse('${constants.url}/room/edit?room_id=$roomId');

    final response = await http.post(
      url,
      headers: _headers(sm.token),
      body: jsonEncode({
        "link": link,
        "title": title,
        "description": description,
        "accepted_emails": convertedAcceptedEmails,
        "cancellation_notice_hours": cancellationHours,
      }),
    );

    _checkUnauthorized(response);
    return response.statusCode == 200;
  }

  Future<bool> deleteRoom(int roomid) async {
    final Uri url = Uri.parse('${constants.url}/room/delete?room_id=$roomid');
    final response = await http.delete(url, headers: _headers(sm.token));

    _checkUnauthorized(response);
    return response.statusCode == 200;
  }

  Future<List<String>> getConnectedUsersInRoom(int roomId) async {
    final Uri url = Uri.parse(
      '${constants.url}/room/get-conected-users?room_id=$roomId',
    );
    final response = await http.get(url, headers: _headers(sm.token));

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

  // --- Blocks ---

  // Optional [now] parameter filters out blocks that start before the given datetime string
  Future<List<BlockModel>> getBlocks(int roomId, [String? now]) async {
    final String query = now != null ? '&start=$now' : '';
    final Uri url = Uri.parse(
      '${constants.url}/block/get?room_id=$roomId$query',
    );
    final response = await http.get(url, headers: _headers(sm.token));

    _checkUnauthorized(response);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is! List) return [];
      return decoded.map((json) => BlockModel.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  // Returns the raw response body (the created block as JSON string) or empty string on failure
  Future<String> createBlock(int id, String date) async {
    final Uri url = Uri.parse('${constants.url}/block/create');
    final response = await http.post(
      url,
      headers: _headers(sm.token),
      body: jsonEncode({"room_id": id, "date": date}),
    );

    _checkUnauthorized(response);

    if (response.statusCode != 200) {
      return "";
    } else {
      return response.body;
    }
  }

  Future<bool> deleteBlock(int blockId) async {
    final Uri url = Uri.parse(
      '${constants.url}/block/delete?block_id=$blockId',
    );
    final response = await http.delete(url, headers: _headers(sm.token));

    _checkUnauthorized(response);
    return response.statusCode == 200;
  }

  Future<void> setBlockOffline(int blockId) async {
    final Uri url = Uri.parse(
      '${constants.url}/block/set-offline?block_id=$blockId',
    );
    final response = await http.post(url, headers: _headers(sm.token));

    _checkUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception('Failed to set block offline ${response.statusCode}');
    }
  }

  Future<void> setBlockOnline(int blockId) async {
    final Uri url = Uri.parse(
      '${constants.url}/block/set-online?block_id=$blockId',
    );
    final response = await http.post(url, headers: _headers(sm.token));

    _checkUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception('Failed to set block online ${response.statusCode}');
    }
  }

  // Subscribes the current user to block availability notifications
  Future<void> subscribeToBlock(int blockId) async {
    final Uri url = Uri.parse(
      '${constants.url}/block/subscribe?block_id=$blockId',
    );
    final response = await http.post(url, headers: _headers(sm.token));

    _checkUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception('Failed to subscribe to block: ${response.statusCode}');
    }
  }

  // Returns a flat list of block IDs the current user is subscribed to
  Future<List<int>> getMySubscriptions() async {
    final Uri url = Uri.parse('${constants.url}/block/get-my-subscriptions');
    final response = await http.get(url, headers: _headers(sm.token));

    _checkUnauthorized(response);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return List<int>.from(decoded.map((json) => json['block_id'] as int));
    } else {
      throw Exception('Failed to get subscriptions: ${response.statusCode}');
    }
  }

  // --- Slots ---

  // Optional [now] filters out slots, returns null on error
  Future<List<SlotModel>?> getSlotsForBlock(int blockId, [String? now]) async {
    final String query = now != null ? '&start=$now' : '';
    final Uri url = Uri.parse('${constants.url}/slot/get?id=$blockId$query');
    final response = await http.get(url, headers: _headers(sm.token));

    _checkUnauthorized(response);

    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body);
      return decoded.map((json) => SlotModel.fromJson(json)).toList();
    } else {
      return null;
    }
  }

  Future<bool> createSlot(
    int block_id,
    String start_time,
    int duration,
    int is_online,
    String note,
  ) async {
    final Uri url = Uri.parse('${constants.url}/slot/create');
    final response = await http.post(
      url,
      headers: _headers(sm.token),
      body: jsonEncode({
        "block_id": block_id,
        // Wrapped in a list, which API supports
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

  Future<void> takeSlot(int id, String note, int is_online) async {
    final Uri url = Uri.parse(
      '${constants.url}/slot/take?slot_id=$id&note=$note&is_online=$is_online',
    );
    final response = await http.post(url, headers: _headers(sm.token));

    _checkUnauthorized(response);

    if (response.statusCode != 200) {
      notify.showToast("Failed to take slot", isError: true);
    }
  }

  Future<void> releaseSlot(int id) async {
    final Uri url = Uri.parse('${constants.url}/slot/release?slot_id=$id');
    final response = await http.post(url, headers: _headers(sm.token));

    _checkUnauthorized(response);

    if (response.statusCode != 200) {
      throw Exception('Failed to release slot: ${response.statusCode}');
    }
  }

  Future<bool> deleteSlot(int slotId) async {
    final Uri url = Uri.parse('${constants.url}/slot/delete?slot_id=$slotId');
    final response = await http.delete(url, headers: _headers(sm.token));

    _checkUnauthorized(response);
    return response.statusCode == 200;
  }

  // Toggles between online and in-person for an already-booked slot
  Future<void> changeConsultationType(int slotId) async {
    final Uri url = Uri.parse(
      '${constants.url}/slot/change-consultation-type?slot_id=$slotId',
    );
    final response = await http.post(url, headers: _headers(sm.token));

    _checkUnauthorized(response);

    if (response.statusCode != 200) {
      notify.showToast("Failed to change consultation type", isError: true);
    }
  }
}
