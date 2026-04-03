import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class CreateRoomViewmodel extends ChangeNotifier {
  List<String> acceptedEmails = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  Future<void> createRoom(
    String shortName,
    String title,
    String description,
  ) async {
    _isLoading = true;
    notifyListeners();
    String token = await prefs.getItem("token");
    String email = await prefs.getItem("email");
    try {
      if (acceptedEmails.isNotEmpty) {
        bool b = await api.createRoom(
          token,
          shortName,
          title,
          description,
          acceptedEmails,
        );
        if (b) {
          notify.showToast('Room was successfully created.');
        } else {
          notify.showToast('Room with provided name already exists.');
        }
      } else {
        notify.showToast('No emails or domain names provided.');
      }
    } catch (e) {
      notify.showToast('Error while creating room.');
    } finally {
      _isLoading = false;
      notifyListeners();
      nav.toTeacherConsultations(token: token, email: email);
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
