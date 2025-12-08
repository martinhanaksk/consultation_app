import 'package:consultation_app/utils/constants.dart';
import 'package:consultation_app/utils/helperFunctions.dart';
import 'package:consultation_app/utils/notifyUserUtils.dart';
import 'package:consultation_app/viewmodels/joinRoom_viewmodel.dart';
import 'package:flutter/material.dart';

class JoinRoom extends StatefulWidget {
  final String token;
  const JoinRoom({super.key, required this.token});

  @override
  State<JoinRoom> createState() => _JoinRoomState();
}

class _JoinRoomState extends State<JoinRoom> {
  final Constants _constants = Constants();
  HelperFunctions helperFunctions = HelperFunctions();
  NotifyUserUtils dialogs = NotifyUserUtils();
  JoinRoomViewmodel _jrvm = JoinRoomViewmodel();
  final TextEditingController idController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _constants.bgLight,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 50),
              Text("Join Room"),
              SizedBox(height: 20),
              TextField(
                controller: idController,
                decoration: const InputDecoration(
                  hintText: 'Type in room id',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (idController.text.trim().isEmpty) {
                      dialogs.showToast('Please type in your email.');
                    } else {
                      if (helperFunctions.isNumeric(idController.text.trim())) {
                        await _jrvm.joinRoom(
                          context,
                          widget.token,
                          idControllerloadData(selectedRoom);.text.trim(),
                        );
                      }
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      _constants.primaryColor,
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Color(0xffffffff),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
