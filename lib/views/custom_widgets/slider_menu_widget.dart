import 'package:consultation_app/viewmodels/slider_menu_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SliderMenu extends StatefulWidget {
  const SliderMenu({super.key});

  @override
  State<SliderMenu> createState() => _SliderMenuState();
}

class _SliderMenuState extends State<SliderMenu> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SliderMenuViewmodel(),
      child: Consumer<SliderMenuViewmodel>(
        builder: (context, viewModel, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            viewModel.checkIfInSharedPreferences();
          });
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
                        const SizedBox(height: 20),
                        GestureDetector(
                          child: Image.asset(
                            'assets/images/applogo.png',

                            width: 100,
                            fit: BoxFit.cover,
                          ),
                          onTap: () {
                            helpers.checkIfValidToken(viewModel.token);
                            viewModel.isTeacher!
                                ? nav.toTeacherConsultations(
                                    token: viewModel.token,
                                    email: viewModel.email!,
                                  )
                                : nav.toStudentConsultations(
                                    token: viewModel.token,
                                    email: viewModel.email!,
                                  );
                          },
                        ),

                        const SizedBox(height: 20),
                        GestureDetector(
                          child: Container(
                            child: Text(
                              "Join Room",
                              style: TextStyle(
                                fontSize: constants.fontSizeSmall,
                              ),
                            ),
                          ),
                          onTap: () {
                            helpers.checkIfValidToken(viewModel.token);
                            nav.toJoinRoom(token: viewModel.token);
                          },
                        ),
                        const SizedBox(height: 20),
                        (viewModel.isTeacher != null && viewModel.isTeacher!)
                            ? Column(
                                children: [
                                  GestureDetector(
                                    child: Container(
                                      child: Text(
                                        "Create Room",
                                        style: TextStyle(
                                          fontSize: constants.fontSizeSmall,
                                        ),
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
                          child: Text(
                            "Provide Feedback",
                            style: TextStyle(fontSize: constants.fontSizeSmall),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text(
                                    "Continue to provide feedback?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        nav.pop();
                                      },
                                      child:  Text("Cancel",style:TextStyle(color: constants.primaryColor)),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        viewModel.launchFeedbackWebsite();
                                      },
                                      child:  Text("Yes",style:TextStyle(color: constants.primaryColor)),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          child: Text(
                            "Settings",
                            style: TextStyle(fontSize: constants.fontSizeSmall),
                          ),

                          onTap: () {
                            nav.toChangeSettings();
                          },
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          child: Text(
                            "Log out",
                            style: TextStyle(
                              fontSize: constants.fontSizeSmall,
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
        },
      ),
    );
  }
}
