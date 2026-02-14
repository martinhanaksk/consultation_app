import 'package:consultation_app/services/user_preferences.dart';
import 'package:consultation_app/utils/constants.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:flutter/material.dart';

class ProvideFeedback extends StatefulWidget {
  const ProvideFeedback({super.key});

  @override
  State<ProvideFeedback> createState() => _ProvideFeedbackState();
}

class _ProvideFeedbackState extends State<ProvideFeedback> {
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
          child: Center(child: Text("Provide Feedback")),
        ),
      ),
    );
  }
}
