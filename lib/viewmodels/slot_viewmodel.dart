import 'package:consultation_app/models/slot_model.dart';
import 'package:consultation_app/services/api_service.dart';
import 'package:consultation_app/utils/notify_user_utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:consultation_app/routes/app_router.dart';

class SlotViewmodel extends ChangeNotifier {
  NotifyUserUtils dialogs = NotifyUserUtils();
  bool isLoading = false;
  final ApiService _apiService = ApiService();
  Future<void> takeSlot(String token, int id, String note) async {
    isLoading = true;
    try {
      await _apiService.takeSlot(token, id, note);
      isLoading = false;
    } catch (e) {
      isLoading = false;
      rethrow;
    }
  }

  Future<void> releaseSlot(String token, int id) async {
    isLoading = true;
    try {
      await _apiService.releaseSlot(token, id);
      isLoading = false;
    } catch (e) {
      isLoading = false;
      rethrow;
    }
  }

  Future<void> showNoteDialog(
    BuildContext context,
    String token,
    int id,
  ) async {
    final TextEditingController _controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add a visit purpose"),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: "Write something..."),
            maxLines: 1,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await takeSlot(token, id, _controller.text.trim());
                Navigator.pop(context);
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }
}
