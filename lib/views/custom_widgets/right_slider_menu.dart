import 'package:consultation_app/routes/app_router.dart';
import 'package:consultation_app/services/user_preferences.dart';
import 'package:consultation_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RightSliderMenu extends StatefulWidget {
  const RightSliderMenu({super.key});

  @override
  State<RightSliderMenu> createState() => _RightSliderMenuState();
}

class _RightSliderMenuState extends State<RightSliderMenu> {
  bool isOpen = false;
  UserPreferences _userPreferences = UserPreferences();
  Constants _constants = Constants();
  @override
  Widget build(BuildContext context) {
    return Drawer(
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
                Image.asset(
                  'assets/images/applogo.png',

                  width: 100,
                  fit: BoxFit.cover,
                ),

                SizedBox(height: 20),
                GestureDetector(
                  child: Container(
                    child: Text("Account", style: TextStyle(fontSize: 20)),
                  ),
                  onTap: () {
                    //todo
                  },
                ),

                SizedBox(height: 20),
                GestureDetector(
                  child: Container(
                    child: Text("Join Room", style: TextStyle(fontSize: 20)),
                  ),
                  onTap: () {
                    //todo
                  },
                ),
                SizedBox(height: 20),
                GestureDetector(
                  child: Container(
                    child: Text("Support", style: TextStyle(fontSize: 20)),
                  ),
                  onTap: () {
                    //todo
                  },
                ),
                SizedBox(height: 20),
                GestureDetector(
                  child: Container(
                    child: Text("Feedback", style: TextStyle(fontSize: 20)),
                  ),
                  onTap: () {
                    //todo
                  },
                ),
              ],
            ),
            Column(
              children: [
                GestureDetector(
                  child: Text("Settings", style: TextStyle(fontSize: 20)),

                  onTap: () {
                    //todo
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

                    // Navigate to login and clear all previous routes
                    Navigator.pushNamed(context, AppRouter.login);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
