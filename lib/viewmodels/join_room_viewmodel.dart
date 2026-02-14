import 'package:consultation_app/services/api_service.dart';
import 'package:consultation_app/utils/notify_user_utils.dart';
import 'package:flutter/material.dart';

class JoinRoomViewmodel {
  NotifyUserUtils dialogs = NotifyUserUtils();
  final ApiService _apiService = ApiService();
  Future<void> joinRoom(BuildContext context, String token, int id) async {
    try {
      await _apiService.joinRoomById(token, id);
      dialogs.showToast('Room joined.');
      Navigator.pop(context);
    } catch (e) {
      dialogs.showToast('Unable to join the room.');
    }
  }
}
