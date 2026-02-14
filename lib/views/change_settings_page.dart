import 'package:consultation_app/setup.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:flutter/material.dart';

class ChangeSettings extends StatefulWidget {
  const ChangeSettings({super.key});

  @override
  State<ChangeSettings> createState() => _ChangeSettingsState();
}

class _ChangeSettingsState extends State<ChangeSettings> {
  String? token = "";
  String? email = "";
  bool? isTeacher;
  @override
  void initState() {
    super.initState();
    checkIfInSharedPreferences();
  }

  void checkIfInSharedPreferences() async {
     token = await prefs.getItem('token');
     email = await prefs.getItem('email');
    String? role = await prefs.getItem('role');
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
      backgroundColor: constants.bgLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(child: Text("Change Settings")),
        ),
      ),
    );
  }
}
