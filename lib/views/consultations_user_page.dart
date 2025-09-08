import 'package:consultation_app/utils/constants.dart';
import 'package:consultation_app/viewmodels/login_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ConsultationsUserPage extends StatefulWidget {
  const ConsultationsUserPage({super.key});

  @override
  State<ConsultationsUserPage> createState() => _ConsultationsUserPageState();
}

class _ConsultationsUserPageState extends State<ConsultationsUserPage> {
  final TextEditingController emailController = TextEditingController();
  LoginViewmodel _lvm = LoginViewmodel();
  Constants _constants = Constants();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _constants.bgLight,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 80),
            Center(
              
              child: Text(
                "Write your self here",
                style: TextStyle(
                  color: _constants.defaultDarkGrey,
                  fontSize: _constants.fontSizeBig,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 80),

            Center(
              child: Column(
                children: [
                  Text(
                    "Štvrtok 22.5",
                    style: TextStyle(
                      color: _constants.defaultDarkGrey,
                      fontSize: _constants.fontSizeSmall,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.7),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: Offset(3, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          width: 350,
                          decoration: BoxDecoration(
                            color: _constants.defaultLightGrey,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "10:00",
                                    style: TextStyle(
                                      color: _constants.defaultDarkGrey,
                                      fontSize: _constants.fontSizeSmall,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),

                                  GestureDetector(
                                    child: Container(
                                      color: _constants.defaultWhite,
                                      padding: EdgeInsets.fromLTRB(
                                        20,
                                        5,
                                        20,
                                        5,
                                      ),
                                      child: Text("Book"),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          width: 350,
                          decoration: BoxDecoration(
                            color: _constants.defaultWhite,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "10:15  Adrian Modry",
                                    style: TextStyle(
                                      color: _constants.defaultDarkGrey,
                                      fontSize: _constants.fontSizeSmall,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "BP",
                                        style: TextStyle(
                                          color: _constants.defaultDarkGrey,
                                          fontSize: _constants.fontSizeSmall,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      GestureDetector(
                                        onTap: () {},
                                        child: SvgPicture.asset(
                                          'assets/images/watchdog-green.svg',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
