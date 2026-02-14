import 'package:consultation_app/routes/app_router.dart';
import 'package:consultation_app/utils/constants.dart';
import 'package:flutter/material.dart';

class AppBarMenu extends StatelessWidget implements PreferredSizeWidget {
  AppBarMenu({super.key});
  final Constants _constants = Constants();
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: _constants.defaultWhite,
      surfaceTintColor: _constants.defaultWhite,
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
