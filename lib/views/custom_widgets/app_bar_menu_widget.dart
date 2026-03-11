import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class AppBarMenu extends StatelessWidget implements PreferredSizeWidget {
  AppBarMenu({super.key});
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: constants.background,
      surfaceTintColor: constants.background,
      leadingWidth: 56,
      leading: Center(
        child: Padding(
          padding: EdgeInsets.only(left: 10),

          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: constants.grey,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.menu_rounded),
              iconSize: 20,
              color: constants.darkGrey,
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 10),
          child: SizedBox(
            width: 45,
            height: 45,
            child: Container(
              decoration: BoxDecoration(
                color: constants.grey,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.person),
                color: constants.darkGrey,
                iconSize: 20,
                onPressed: () {
                  nav.toChangeSettings();
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
