// create_room_viewmodel.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// ViewModel for the Create Room screen. Extends BaseRoomViewmodel and adds
// the createRoom action, which validates the accepted-email list
// before calling the API.

import 'package:consultation_app/setup.dart';
import 'base_room_viewmodel.dart';

class CreateRoomViewmodel extends BaseRoomViewmodel {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  // ── Public Methods ─────────────────────────────────────────────────────────
  Future<void> createRoom(
    String link,
    String title,
    String description,
    int cancellationHours,
  ) async {
    // At least one allowed email or domain is required before creating the room
    if (acceptedEmails.isEmpty) {
      notify.showToast('No emails or domain names provided');
      return;
    }

    _setLoading(true);
    try {
      final success = await api.createRoom(
        link,
        title,
        description,
        cancellationHours,
        acceptedEmails,
      );
      if (success) {
        notify.showToast('Room was successfully created');
        nav.toOwnerConsultations();
      } else {
        // A false response means the short name is already taken
        notify.showToast('Room with provided name already exists');
      }
    } catch (_) {
      notify.showToast('Error while creating room', isError: true);
    } finally {
      _setLoading(false);
    }
  }

  // ── Private Helpers ────────────────────────────────────────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
