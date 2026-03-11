import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class CreateRoomViewmodel extends ChangeNotifier {
  Future<void> createRoom() async {
    String token = await prefs.getItem("token");
    String shortName = "test", title = "test", description = "test";
    List<String> acceptedEmailsArray = ["@gmail.com", "gmail.com"];
    try {
      bool b = await api.createRoom(
        token,
        shortName,
        title,
        description,
        acceptedEmailsArray,
      );
      if (b) {
        notify.showToast('Room was successfully created.');
        print('Room was successfully created.');
      }
    } catch (e) {
      print(e.toString());
      notify.showToast('Error while creating room.');
    }
  }
}
