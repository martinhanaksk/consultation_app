// display_users_in_room_page.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// base_room_viewmodel.dart
// Shared state and behaviour for CreateRoomViewmodel and EditRoomViewmodel.

import 'package:flutter/material.dart';

abstract class BaseRoomViewmodel extends ChangeNotifier {
  final TextEditingController shortNameController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController acceptedEmailController = TextEditingController();
  final TextEditingController cancellationHoursController = TextEditingController();

  List<String> acceptedEmails = [];

  void addToAcceptedEmails(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || acceptedEmails.contains(trimmed)) return;
    acceptedEmails.add(trimmed);
    acceptedEmailController.clear();
    notifyListeners();
  }

  void removeFromAcceptedEmails(String value) {
    acceptedEmails.remove(value);
    notifyListeners();
  }

  @override
  void dispose() {
    shortNameController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    acceptedEmailController.dispose();
    cancellationHoursController.dispose();
    super.dispose();
  }
}
