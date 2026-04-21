import 'package:flutter/material.dart';
import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/setup.dart';

class EditRoomViewmodel extends ChangeNotifier {
  final TextEditingController shortNameController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController acceptedEmailsController = TextEditingController();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  RoomModel? room;
  String? errorMessage;

  Future<void> loadData(String token, int roomId) async {
    _setLoading(true);
    try {
      List<RoomModel> allRooms = await api.getAllRooms(token);
      room = allRooms.firstWhere((r) => r.id == roomId);

      shortNameController.text = room!.shortName;
      titleController.text = room!.title;
      descriptionController.text = room!.description;
      acceptedEmailsController.text = room!.acceptedEmails;
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Failed to load room details: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> submitChanges(String token) async {
    if (room == null) return false;

    // Basic Validation
    if (shortNameController.text.isEmpty ||
        titleController.text.isEmpty ||
        acceptedEmailsController.text.isEmpty) {
      errorMessage = 'Please fill out all required fields.';
      notifyListeners();
      return false;
    }

    _setSaving(true);
    try {
      List<String> emailList = acceptedEmailsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      bool success = await api.editRoom(
        token,
        room!.id,
        shortNameController.text,
        titleController.text,
        descriptionController.text,
        emailList,
      );

      return success;
    } catch (e) {
      errorMessage = 'Error: $e';
      return false;
    } finally {
      _setSaving(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    shortNameController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    acceptedEmailsController.dispose();
    super.dispose();
  }
}
