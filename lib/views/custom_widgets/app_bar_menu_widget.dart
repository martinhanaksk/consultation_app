// app_bar_menu_widget.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Shared app bar used across all pages.
// Leading button: hamburger (drawer) on the home page, back arrow elsewhere.
// Trailing button: settings icon, hidden on the settings, verification, and registration pages.
// An optional toggle widget (e.g. AnimatedToggle) is centred in the flexible space.

import 'package:consultation_app/viewmodels/base_consultations_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class AppBarMenu extends StatelessWidget implements PreferredSizeWidget {
  final BaseConsultationsViewmodel? viewModel;
  // Optional centre widget; used for the owner/student AnimatedToggle on the home page
  final Widget? toggle;
  final bool onHomePage;
  final bool onVerificationPage;
  final bool onRegistrationPage;
  final bool onSettingsPage;

  const AppBarMenu({
    super.key,
    this.viewModel,
    this.toggle,
    this.onHomePage = false,
    this.onVerificationPage = false,
    this.onSettingsPage = false,
    this.onRegistrationPage = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: constants.background,
      // Prevents the Material 3 surface tint from tinting the app bar on scroll
      surfaceTintColor: constants.background,
      leadingWidth: 56,
      leading: Center(
        child: Padding(
          padding: EdgeInsets.only(left: 12),
          child: onHomePage
              // Home page: hamburger opens the drawer
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
                      'hamburger',
                      constants.darkGrey,
                      width: constants.fsTitle,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                )
              // All other pages: back arrow with smart navigation to avoid
              // pushing the consultations list on top of itself
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
                      'arrow_left',
                      constants.darkGrey,
                      width: constants.fsTitle,
                    ),
                    onPressed: () {
                      if (nav.previousRoute == "/consultationsOwnerPage") {
                        nav.toOwnerConsultations();
                      } else if (nav.previousRoute ==
                          "/consultationsBasePage") {
                        nav.toBaseConsultations();
                      } else {
                        nav.pop();
                      }
                    },
                  ),
                ),
        ),
      ),
      // toggle is null on most pages
      flexibleSpace: SafeArea(child: Center(child: toggle)),
      actions: [
        // Settings icon is hidden on pages where navigating to settings makes no sense
        onSettingsPage || onVerificationPage || onRegistrationPage
            ? SizedBox.shrink()
            : Padding(
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
                        'settings',
                        constants.darkGrey,
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
