import 'package:consultation_app/routes/appRouter.dart';
import 'package:consultation_app/services/userPreferences.dart';
import 'package:consultation_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SliderMenu extends StatefulWidget {
  final String token;
  const SliderMenu({super.key,required this.token});

  @override
  State<SliderMenu> createState() => _SliderMenuState();
}

class _SliderMenuState extends State<SliderMenu> {
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
                    child: Text("Join Room", style: TextStyle(fontSize: 20)),
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.joinRoom,
                      arguments: {'token': widget.token},
                    );
                  },
                ),
                SizedBox(height: 20),
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
    );
  }
}
