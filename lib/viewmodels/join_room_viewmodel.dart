import 'package:consultation_app/models/user_model.dart';
import 'package:consultation_app/services/api_service.dart';
import 'package:consultation_app/utils/notify_user_utils.dart';
import 'package:consultation_app/views/consultations_student_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:consultation_app/routes/app_router.dart';

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
