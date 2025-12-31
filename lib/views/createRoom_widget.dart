import 'package:consultation_app/services/userPreferences.dart';
import 'package:consultation_app/utils/constants.dart';
import 'package:consultation_app/views/custom_widgets/appBarMenu_widget.dart';
import 'package:consultation_app/views/custom_widgets/sliderMenu_widget.dart';
import 'package:flutter/material.dart';

class CreateRoom extends StatefulWidget {
  const CreateRoom({super.key});

  @override
  State<CreateRoom> createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> {
  final Constants _constants = Constants();
  String? token = "";
  String? email = "";
  bool? isTeacher;
  UserPreferences _userPreferences = UserPreferences();
  @override
  void initState() {
    super.initState();
    checkIfInSharedPreferences();
  }

  void checkIfInSharedPreferences() async {
    token = await _userPreferences.getItem('token');
    email = await _userPreferences.getItem('email');
    String? role = await _userPreferences.getItem('role');
    if (role == 'teacher') {
      isTeacher = true;
    } else {
      isTeacher = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarMenu(),
      drawer: SliderMenu(
       
      ),
      backgroundColor: _constants.bgLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(child: Text("Create Room")),
        ),
      ),
    );
  }
}
