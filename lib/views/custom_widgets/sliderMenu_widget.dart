import 'package:consultation_app/routes/appRouter.dart';
import 'package:consultation_app/services/userPreferences.dart';
import 'package:consultation_app/utils/constants.dart';
import 'package:consultation_app/views/consultationsStudent_page.dart';
import 'package:consultation_app/views/consultationsTeacher_page.dart';
import 'package:flutter/material.dart';

class SliderMenu extends StatefulWidget {
  const SliderMenu({super.key});

  @override
  State<SliderMenu> createState() => _SliderMenuState();
}

class _SliderMenuState extends State<SliderMenu> {
  bool isOpen = false;
  UserPreferences _userPreferences = UserPreferences();
  String? token = "";
  String? email = "";
  bool? isTeacher;
  Constants _constants = Constants();
  @override
  void initState() {
    super.initState();
    checkIfInSharedPreferences();
  }

  Future<bool> getIsTeacher() async {
    String? role = await _userPreferences.getItem('role');
    if (role == 'teacher') {
      return true;
    }
    return false;
  }

  void checkIfInSharedPreferences() async {
    token = await _userPreferences.getItem('token');
    email = await _userPreferences.getItem('email');
    bool isTeacherTemp = await getIsTeacher();
    if (mounted) {
      setState(() {
        isTeacher = isTeacherTemp;
      });
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
                      isTeacher!
                          ? Navigator.pushNamed(
                              context,
                              AppRouter.consultationsTeacherPage,
                              arguments: ConsultationsTeacherPageArgs(
                                token: token!,
                                email: email!,
                              ),
                            )
                          : Navigator.pushNamed(
                              context,
                              AppRouter.consultationsStudentPage,
                              arguments: ConsultationsStudentPageArgs(
                                token: token!,
                                email: email!,
                              ),
                            );
                    },
                  ),

                  SizedBox(height: 20),
                  GestureDetector(
                    child: Container(
                      child: Text("Join Room", style: TextStyle(fontSize: 20)),
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.joinRoom,
                        arguments: {'token': token},
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  (isTeacher!)
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
                                Navigator.pushNamed(
                                  context,
                                  AppRouter.createRoom,
                                  arguments: {'token': token, 'email': email},
                                );
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
                      Navigator.pushNamed(context, AppRouter.support);
                    },
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    child: Container(
                      child: Text("Feedback", style: TextStyle(fontSize: 20)),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, AppRouter.provideFeedback);
                    },
                  ),
                ],
              ),
              Column(
                children: [
                  GestureDetector(
                    child: Text("Settings", style: TextStyle(fontSize: 20)),

                    onTap: () {
                      Navigator.pushNamed(context, AppRouter.changeSettings);
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
                      await _userPreferences.removeItem('token');
                      await _userPreferences.removeItem('email');
                      await _userPreferences.removeItem('role');
                      // Navigate to login and clear all previous routes
                      Navigator.pushNamed(context, AppRouter.login);
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
