import 'package:consultation_app/utils/constants.dart';
import 'package:consultation_app/utils/helperFunctions.dart';
import 'package:consultation_app/utils/notifyUserUtils.dart';
import 'package:flutter/material.dart';

class CreateRoom extends StatefulWidget {
  final String token;
  const CreateRoom({super.key, required this.token});

  @override
  State<CreateRoom> createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> {
  final Constants _constants = Constants();
  HelperFunctions helperFunctions = HelperFunctions();
  NotifyUserUtils dialogs = NotifyUserUtils();
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
              Text("Create Room"),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
