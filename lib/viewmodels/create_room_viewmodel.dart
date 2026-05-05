// create_room_viewmodel.dart
import 'package:consultation_app/setup.dart';
import 'base_room_viewmodel.dart';

class CreateRoomViewmodel extends BaseRoomViewmodel {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> createRoom(
    String shortName,
    String title,
    String description,
    int cancellationHours,
  ) async {
    if (acceptedEmails.isEmpty) {
      notify.showToast('No emails or domain names provided');
      return;
    }

    _setLoading(true);
    try {
      final success = await api.createRoom(
        shortName,
        title,
        description,
        cancellationHours,
        acceptedEmails,
      );

      if (success) {
        notify.showToast('Room was successfully created');
        nav.toOwnerConsultations();
      } else {
        notify.showToast('Room with provided name already exists');
      }
    } catch (e) {
      notify.showToast('Error while creating room', isError: true);
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
