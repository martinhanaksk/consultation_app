import 'package:consultation_app/models/user_model.dart';
import 'package:consultation_app/services/apiService.dart';
import 'package:consultation_app/utils/notifyUserUtils.dart';
import 'package:consultation_app/views/consultationsStudent_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:consultation_app/routes/appRouter.dart';

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
