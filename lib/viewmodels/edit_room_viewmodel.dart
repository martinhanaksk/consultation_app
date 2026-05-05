// edit_room_viewmodel.dart
import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/setup.dart';
import 'base_room_viewmodel.dart';

class EditRoomViewmodel extends BaseRoomViewmodel {
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  RoomModel? room;
  String? errorMessage;

  Future<void> loadData(int roomId) async {
    _setLoading(true);
    try {
      final allRooms = await api.getAllRooms();
      room = allRooms.firstWhere((r) => r.id == roomId);

      shortNameController.text = room!.shortName;
      titleController.text = room!.title;
      descriptionController.text = room!.description;
      cancellationHoursController.text = room!.cancellationNoticeHours.toString();

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
        shortNameController.text.trim(),
        titleController.text.trim(),
        descriptionController.text.trim(),
        int.parse(cancellationHoursController.text.trim()),
        acceptedEmails,
      );
    } catch (e) {
      errorMessage = 'Error: $e';
      return false;
    } finally {
      _setSaving(false);
    }
  }

  bool _anyFieldEmpty() =>
      shortNameController.text.isEmpty ||
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

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
