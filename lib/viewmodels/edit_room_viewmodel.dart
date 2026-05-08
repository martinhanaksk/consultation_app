// edit_room_viewmodel.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// ViewModel for the Edit Room screen. Loads existing room data into the
// inherited controllers and submits changes via the API.

import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/setup.dart';
import 'base_room_viewmodel.dart';

class EditRoomViewModel extends BaseRoomViewModel {
  RoomModel? room;
  String? errorMessage;

  bool _isLoading = true;
  bool _isSaving = false;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  // ── Public Methods ───────────────────────────────────────────────────────────────────────────

  Future<void> loadData(int roomId) async {
    _setLoading(true);
    try {
      final allRooms = await api.getAllRooms();
      room = allRooms.firstWhere((r) => r.id == roomId);

      // Pre-populate the inherited form controllers with the current room values
      linkController.text = room!.link;
      titleController.text = room!.title;
      descriptionController.text = room!.description;
      cancellationHoursController.text = room!.cancellationNoticeHours
          .toString();
      // The API returns a comma-separated string. Split into the list used by the form
      acceptedEmails = room!.acceptedEmails
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      acceptedEmailController.clear();
      errorMessage = null;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to load room details: \$e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> handleSave() async {
    clearError();
    final success = await _submitChanges();
    if (success) {
      notify.showToast('Room updated successfully');
      nav.toOwnerConsultations();
    } else {
      notify.showToast(errorMessage ?? 'Failed to update room', isError: true);
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  // ── Private Helpers ────────────────────────────────────────────────────────────────────────────

  Future<bool> _submitChanges() async {
    if (room == null) return false;

    if (_anyFieldEmpty()) {
      errorMessage = 'Please fill out all required fields.';
      notifyListeners();
      return false;
    }

    _setSaving(true);
    try {
      return await api.editRoom(
        room!.id,
        linkController.text.trim(),
        titleController.text.trim(),
        descriptionController.text.trim(),
        int.parse(cancellationHoursController.text.trim()),
        acceptedEmails,
      );
    } catch (e) {
      errorMessage = 'Error: \$e';
      return false;
    } finally {
      _setSaving(false);
    }
  }

  // Validates that no required field is empty before attempting to save
  bool _anyFieldEmpty() =>
      linkController.text.isEmpty ||
      titleController.text.isEmpty ||
      descriptionController.text.isEmpty ||
      cancellationHoursController.text.isEmpty ||
      acceptedEmails.isEmpty;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }
}
