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
          padding: EdgeInsets.only(left: 12),

          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: constants.grey,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.menu_rounded),
              iconSize: constants.fsBody,
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
          padding: EdgeInsets.only(right: 12),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Container(
              decoration: BoxDecoration(
                color: constants.grey,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.person_2_outlined),
                color: constants.darkGrey,
                iconSize: constants.fsBody,
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
