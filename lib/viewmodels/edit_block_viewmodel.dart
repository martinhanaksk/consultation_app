import 'package:consultation_app/setup.dart';
import 'package:flutter/material.dart';

class EditBlockViewmodel extends ChangeNotifier {
  Future<void> deleteBlock(String token, int blockId) async {
    bool deleted = await api.deleteBlock(token, blockId);
    if (deleted) {
      notify.showToast("Block was deleted successfully.");
    } else {
      notify.showToast("Block could not be deleted.");
    }
  }
}

enum TimePickerAction { startTime, endTime, duration }
