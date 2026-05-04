import 'package:flutter/material.dart';
import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/setup.dart';

class EditRoomViewmodel extends ChangeNotifier {
  final TextEditingController shortNameController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController acceptedEmailController = TextEditingController();
  final TextEditingController cancellationHoursController =
      TextEditingController();

  List<String> acceptedEmails = [];

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  RoomModel? room;
  String? errorMessage;

  Future<void> loadData(int roomId) async {
    _setLoading(true);
    try {
      List<RoomModel> allRooms = await api.getAllRooms();
      room = allRooms.firstWhere((r) => r.id == roomId);

      shortNameController.text = room!.shortName;
      titleController.text = room!.title;
      descriptionController.text = room!.description;
      cancellationHoursController.text = room!.cancellationNoticeHours
          .toString();

      acceptedEmails = room!.acceptedEmails
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      acceptedEmailController.clear();
      errorMessage = null;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to load room details: $e';
    } finally {
      _setLoading(false);
    }
  }

  void addToAcceptedEmails(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;

    if (!acceptedEmails.contains(trimmed)) {
      acceptedEmails.add(trimmed);
      acceptedEmailController.clear();
      notifyListeners();
    }
  }

  void removeFromAcceptedEmails(String value) {
    acceptedEmails.remove(value);
    notifyListeners();
  }

  Future<void> handleSave() async {
    clearError();
    bool success = await submitChanges();

    if (success) {
      notify.showToast("Room updated successfully");
      nav.toOwnerConsultations();
    } else if (errorMessage != null) {
      notify.showToast(errorMessage!,isError: true);
    } else {
      notify.showToast('Failed to update room',isError: true);
    }
  }

  Future<bool> submitChanges() async {
    if (room == null) return false;

    if (shortNameController.text.isEmpty ||
        titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        cancellationHoursController.text.isEmpty ||
        acceptedEmails.isEmpty) {
      errorMessage = 'Please fill out all required fields.';
      notifyListeners();
      return false;
    }

    _setSaving(true);
    try {
      bool success = await api.editRoom(
        
        room!.id,
        shortNameController.text.trim(),
        titleController.text.trim(),
        descriptionController.text.trim(),
        int.parse(cancellationHoursController.text.trim()),
        acceptedEmails,
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
    acceptedEmailController.dispose();
    super.dispose();
  }
}
