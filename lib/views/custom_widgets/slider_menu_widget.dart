import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class SliderMenu extends StatefulWidget {
  const SliderMenu({super.key});

  @override
  State<SliderMenu> createState() => _SliderMenuState();
}

class _SliderMenuState extends State<SliderMenu> {
  bool isOpen = false;
  String token = "";
  String? email = "";
  bool? isTeacher;
  @override
  void initState() {
    super.initState();
    checkIfInSharedPreferences();
  }

  Future<bool> getIsTeacher() async {
    String? role = await prefs.getItem('role');
    if (role == 'teacher') {
      return true;
    }
    return false;
  }

  void checkIfInSharedPreferences() async {
    token = await prefs.getItem('token');
    helpers.checkIfValidToken(token);
    email = await prefs.getItem('email');
    if (!await helpers.handleIsInternetConnection()) {
      notify.showToast('Please connect to internet.');
    } else {
      bool isTeacherTemp = await getIsTeacher();
      if (mounted) {
        setState(() {
          isTeacher = isTeacherTemp;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        width: 220,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  GestureDetector(
                    child: Image.asset(
                      'assets/images/applogo.png',

                      width: 100,
                      fit: BoxFit.cover,
                    ),
                    onTap: () {
    helpers.checkIfValidToken(token);
                      isTeacher!
                          ? nav.toTeacherConsultations(
                              token: token,
                              email: email!,
                            )
                          : nav.toStudentConsultations(
                              token: token,
                              email: email!,
                            );
                    },
                  ),

                  SizedBox(height: 20),
                  GestureDetector(
                    child: Container(
                      child: Text("Join Room", style: TextStyle(fontSize: 20)),
                    ),
                    onTap: () {
    helpers.checkIfValidToken(token);
                      nav.toJoinRoom(token: token);
                    },
                  ),
                  SizedBox(height: 20),
                  (isTeacher != null && isTeacher!)
                      ? Column(
                          children: [
                            GestureDetector(
                              child: Container(
                                child: Text(
                                  "Create Room",
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                              onTap: () {
                                nav.toCreateRoom();
                              },
                            ),
                            SizedBox(height: 20),
                          ],
                        )
                      : SizedBox(height: 0),
                  GestureDetector(
                    child: Container(
                      child: Text("Support", style: TextStyle(fontSize: 20)),
                    ),
                    onTap: () {
                      nav.toSupport();
                    },
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    child: Container(
                      child: Text("Feedback", style: TextStyle(fontSize: 20)),
                    ),
                    onTap: () {
                      nav.toProvideFeedback();
                    },
                  ),
                ],
              ),
              Column(
                children: [
                  GestureDetector(
                    child: Text("Settings", style: TextStyle(fontSize: 20)),

                    onTap: () {
                      nav.toChangeSettings();
                    },
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    child: Text(
                      "Log out",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    onTap: () async {
                      await prefs.removeItem('token');
                      await prefs.removeItem('email');
                      await prefs.removeItem('role');
                      // Navigate to login and clear all previous routes
                      nav.toLogin();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
