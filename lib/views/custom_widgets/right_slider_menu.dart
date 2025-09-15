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
  Constants _constants = Constants();
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Consultations",
                  style: TextStyle(
                    color: _constants.defaultDarkGrey,
                    fontSize: _constants.fontSizeMedium,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 10),
                Text("Account"),
                SizedBox(height: 10),
                Text("Join Consultation"),
                SizedBox(height: 10),
                Text("Create Consultations"),
                SizedBox(height: 10),
                Text("Support"),
                SizedBox(height: 10),
                Text("Feedback"),
              ],
            ),
            Text("Settings"),
          ],
        ),
      ),
    );
  }
}
