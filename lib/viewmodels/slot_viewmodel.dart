import 'package:consultation_app/setup.dart';
import 'package:flutter/material.dart';

class SlotViewmodel extends ChangeNotifier {
  bool _isLoading = false;
  Future<void> takeSlot(String token, int id, String note) async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    try {
      await api.takeSlot(token, id, note);
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      rethrow;
    }
  }

  Future<void> releaseSlot(String token, int id) async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    try {
      await api.releaseSlot(token, id);
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
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
              child: Text(
                "Cancel",
                style: TextStyle(color: constants.primaryColor),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await takeSlot(token, id, _controller.text.trim());
                nav.pop();
              },
              child: Text(
                "Submit",
                style: TextStyle(color: constants.primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }
}
