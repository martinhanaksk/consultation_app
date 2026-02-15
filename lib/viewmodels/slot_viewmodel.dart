import 'package:consultation_app/setup.dart';
import 'package:flutter/material.dart';

class SlotViewmodel extends ChangeNotifier {
  bool isLoading = false;
  Future<void> takeSlot(String token, int id, String note) async {
    isLoading = true;
    try {
      await api.takeSlot(token, id, note);
      isLoading = false;
    } catch (e) {
      isLoading = false;
      rethrow;
    }
  }

  Future<void> releaseSlot(String token, int id) async {
    isLoading = true;
    try {
      await api.releaseSlot(token, id);
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
