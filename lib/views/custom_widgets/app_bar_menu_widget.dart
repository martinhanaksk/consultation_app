import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class AppBarMenu extends StatelessWidget implements PreferredSizeWidget {
  AppBarMenu({super.key});
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: constants.defaultWhite,
      surfaceTintColor: constants.defaultWhite,
      actionsPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      leading: IconButton(
        icon: Icon(Icons.menu_rounded),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      actions: [
        Container(
          child: IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              nav.toChangeSettings();
            },
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
