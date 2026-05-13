// base_room_viewmodel.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Shared state and behaviour for CreateRoomPageViewModel and EditRoomViewModel.
// Owns all form controllers and the accepted-email list

import 'package:flutter/material.dart';

abstract class BaseRoomViewModel extends ChangeNotifier {
  final TextEditingController linkController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController acceptedEmailController = TextEditingController();
  final TextEditingController cancellationHoursController =
      TextEditingController();
  // Prevents notifyListeners() from firing after the widget tree is disposed
  bool _disposed = false;
  List<String> acceptedEmails = [];

  void addToAcceptedEmails(String value) {
    final trimmed = value.trim();
    // Ignore empty input or duplicates
    if (trimmed.isEmpty || acceptedEmails.contains(trimmed)) return;
    acceptedEmails.add(trimmed);
    // Clear the input field after a successful add
    acceptedEmailController.clear();
    notifyListeners();
  }

  void removeFromAcceptedEmails(String value) {
    acceptedEmails.remove(value);
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    linkController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    acceptedEmailController.dispose();
    cancellationHoursController.dispose();
    super.dispose();
  }

  // Overridden to guard against async callbacks firing after dispose()
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }
}
