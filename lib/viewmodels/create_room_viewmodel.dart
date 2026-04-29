import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class CreateRoomViewmodel extends ChangeNotifier {
  final TextEditingController roomNameController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController acceptedEmailController = TextEditingController();
  final TextEditingController cancellationHoursController =
      TextEditingController();
  List<String> acceptedEmails = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  Future<void> createRoom(
    String shortName,
    String title,
    String description,
    int cancellationHours,
  ) async {
    _isLoading = true;
    notifyListeners();
    String token = await securePrefs.getToken();
    String email = await prefs.getItem("email");
    try {
      if (acceptedEmails.isNotEmpty) {
        bool b = await api.createRoom(
          token,
          shortName,
          title,
          description, cancellationHours,
          acceptedEmails,
        );
        if (b) {
          notify.showToast('Room was successfully created.');
          _isLoading = false;
          notifyListeners();
          nav.toOwnerConsultations(token: token, email: email);
        } else {
          notify.showToast('Room with provided name already exists.');
          _isLoading = false;
          notifyListeners();
        }
      } else {
        notify.showToast('No emails or domain names provided.');
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      notify.showToast('Error while creating room.');
      _isLoading = false;
      notifyListeners();
    }
  }

  void addToAcceptedEmails(String value) {
    acceptedEmails.add(value);
    notifyListeners();
  }

  void removeFromAcceptedEmails(String value) {
    acceptedEmails.remove(value);
    notifyListeners();
  }
}
