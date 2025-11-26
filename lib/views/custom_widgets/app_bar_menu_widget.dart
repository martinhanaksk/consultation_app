import 'package:consultation_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppBarMenu extends StatelessWidget implements PreferredSizeWidget {
  AppBarMenu({super.key});
  Constants _constants = Constants();
  @override
  Widget build(BuildContext context) {
    return AppBar(
      actionsPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      leading: IconButton(
        icon: Icon(Icons.menu, size: 50.0),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      actions: [
        Container(
          decoration: BoxDecoration(
            color: _constants.defaultDarkGrey,
            borderRadius: BorderRadius.circular(50),
          ),

          child: IconButton(
            icon: Icon(Icons.person),
            color: _constants.defaultWhite,
            onPressed: () {
              // print("profile opened");
            },
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
