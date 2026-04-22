import 'package:consultation_app/viewmodels/base_consultations_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class AppBarMenu extends StatelessWidget implements PreferredSizeWidget {
  final BaseConsultationsViewmodel? viewModel;
  final String? token;
  final Widget? toggle;
  final bool onHomePage;

  AppBarMenu({
    super.key,
    this.viewModel,
    this.toggle,
    this.token,
    this.onHomePage = false,
  });
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: constants.background,
      surfaceTintColor: constants.background,
      leadingWidth: 56,
      leading: Center(
        child: Padding(
          padding: EdgeInsets.only(left: 12),

          child: onHomePage
              ? Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: constants.grey,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: svgs.icon(
                      'hamburger',constants.darkGrey,
                      width: constants.fsTitle
                    ),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                )
              : Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: constants.grey,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: svgs.icon(
                      'back',constants.darkGrey,
                      width: constants.fsTitle,
                      
                    ),
                    onPressed: () {
                      nav.pop();
                    },
                  ),
                ),
        ),
      ),
      flexibleSpace: SafeArea(child: Center(child: toggle)),
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
                icon: svgs.icon(
                  'person',constants.darkGrey,
                  width: constants.fsBody,
                  
                ),
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
