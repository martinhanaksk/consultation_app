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

  void init(String rawHistory) {
    _isLoading = true;
    _hasError = false;
  
      notifyListeners();
      try {
        List<dynamic> decodedList = jsonDecode(rawHistory);
        List<String> stringList = decodedList.cast<String>();

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
