import 'package:consultation_app/routes/appRouter.dart';
import 'package:flutter/material.dart';

class AppBarMenu extends StatelessWidget implements PreferredSizeWidget {
  AppBarMenu({super.key});
  @override
  Widget build(BuildContext context) {
    return AppBar(
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
              Navigator.pushNamed(context, AppRouter.changeSettings);
            },
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
