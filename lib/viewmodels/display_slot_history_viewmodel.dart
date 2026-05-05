// display_slot_history_viewmodel.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// ViewModel for the Slot History screen. Parses a raw JSON string of history
// entries (each formatted as "user - date") for display.

import 'dart:convert';
import 'package:flutter/foundation.dart';

class HistoryItem {
  final String user;
  final String date;
  HistoryItem({required this.user, required this.date});
}

class DisplaySlotHistoryViewModel extends ChangeNotifier {
  List<HistoryItem> _historyItems = [];
  bool _isLoading = false;
  bool _hasError = false;
  List<HistoryItem> get historyItems => _historyItems;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  // Parses rawHistory, which is a JSON-encoded list of strings in the form
  void init(String rawHistory) {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      List<dynamic> decodedList = jsonDecode(rawHistory);
      List<String> stringList = decodedList.cast<String>();

      // Split each entry on " - " to separate the email from the date
      _historyItems = stringList.map((entry) {
        List<String> parts = entry.split(" - ");
        return HistoryItem(
          user: parts.isNotEmpty ? parts[0].trim() : "Unknown User",
          date: parts.length > 1 ? parts[1].trim() : "",
        );
      }).toList();

      _hasError = false;
    } catch (e) {
      _hasError = true;
      _historyItems = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
