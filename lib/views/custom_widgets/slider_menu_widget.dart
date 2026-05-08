// slider_menu.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Side drawer navigation menu. Renders owner-only items conditionally and
// handles token validation.

import 'package:consultation_app/viewmodels/slider_menu_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';
import 'package:provider/provider.dart';

class SliderMenu extends StatefulWidget {
  const SliderMenu({super.key});

  @override
  State<SliderMenu> createState() => _SliderMenuState();
}

class _SliderMenuState extends State<SliderMenu> {
  late final SliderMenuViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SliderMenuViewModel();
    // Loads data the menu needs before first paint
    _viewModel.checkSliderMenuFundamentals();
  }

  @override
  Widget build(BuildContext context) {
    _viewModel.checkSliderMenuFundamentals();
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<SliderMenuViewModel>(
        builder: (context, viewModel, child) {
          return SafeArea(
            child: Drawer(
              backgroundColor: constants.background,
              width: 240,
              child: NotificationListener<ScrollStartNotification>(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                  child: Column(
                    // Top group (nav links) pushed apart from bottom group (settings/logout)
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Top navigation group ──────────────────────────────
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: GestureDetector(
                              child: svgs.icon(
                                "logo-whole",
                                constants.primary,
                                width: 120,
                              ),
                              onTap: () {
                                // Verify the session token is still valid before navigating
                                sm.checkIfValidToken();
                                if (viewModel.isOwner != null) {
                                  viewModel.isOwner!
                                      ? nav.toOwnerConsultations()
                                      : nav.toBaseConsultations();
                                  viewModel.closeDrawer(context);
                                } else {
                                  notify.showToast(
                                    "Check your internet connection",
                                    isError: true,
                                  );
                                }
                              },
                            ),
                          ),

                          const SizedBox(height: 20),
                          GestureDetector(
                            child: Row(
                              children: [
                                svgs.icon(
                                  "home",
                                  constants.darkGrey,
                                  width: 22,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Home",
                                  style: TextStyle(
                                    fontSize: constants.fsBody,
                                    color: constants.darkGrey,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              sm.checkIfValidToken();
                              if (viewModel.isOwner != null) {
                                viewModel.isOwner!
                                    ? nav.toOwnerConsultations()
                                    : nav.toBaseConsultations();
                                viewModel.closeDrawer(context);
                              } else {
                                notify.showToast(
                                  "Check your internet connection",
                                  isError: true,
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            child: Row(
                              children: [
                                svgs.icon("my", constants.darkGrey, width: 24),
                                const SizedBox(width: 10),
                                Text(
                                  "My reservations",
                                  style: TextStyle(
                                    fontSize: constants.fsBody,
                                    color: constants.darkGrey,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              sm.checkIfValidToken();
                              nav.toMyReservations();
                              viewModel.closeDrawer(context);
                            },
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            child: Row(
                              children: [
                                svgs.icon(
                                  "join",
                                  constants.darkGrey,
                                  width: 24,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Join Room",
                                  style: TextStyle(
                                    fontSize: constants.fsBody,
                                    color: constants.darkGrey,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              sm.checkIfValidToken();
                              nav.toJoinRoomPage();
                              viewModel.closeDrawer(context);
                            },
                          ),
                          const SizedBox(height: 20),
                          // "Create Room" is only available to owners
                          (viewModel.isOwner != null && viewModel.isOwner!)
                              ? Column(
                                  children: [
                                    GestureDetector(
                                      child: Row(
                                        children: [
                                          svgs.icon(
                                            "create",
                                            constants.darkGrey,
                                            width: 20,
                                          ),
                                          const SizedBox(width: 14),
                                          Text(
                                            "Create Room",
                                            style: TextStyle(
                                              fontSize: constants.fsBody,
                                              color: constants.darkGrey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        sm.checkIfValidToken();
                                        nav.toCreateRoomPage();
                                        viewModel.closeDrawer(context);
                                      },
                                    ),
                                    SizedBox(height: 20),
                                  ],
                                )
                              : SizedBox.shrink(),

                          // Opens a confirmation dialog before launching the external feedback URL
                          GestureDetector(
                            child: Row(
                              children: [
                                svgs.icon(
                                  "feedback",
                                  constants.darkGrey,
                                  width: 22,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Provide Feedback",
                                  style: TextStyle(
                                    fontSize: constants.fsBody,
                                    color: constants.darkGrey,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              sm.checkIfValidToken();
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: constants.background,
                                    title: Text(
                                      "Continue to provide feedback?",
                                      style: TextStyle(
                                        fontSize: constants.fsBody,
                                        color: constants.darkGrey,
                                      ),
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          FocusScope.of(context).unfocus();
                                          nav.pop();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: constants.background,
                                          disabledBackgroundColor:
                                              constants.background,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          elevation: 2,
                                          shadowColor: constants.background,
                                        ),
                                        child: Text(
                                          "Cancel",
                                          style: TextStyle(
                                            color: constants.primary,
                                            fontSize: constants.fsLabel,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          FocusScope.of(context).unfocus();
                                          viewModel.launchFeedbackWebsite();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: constants.primary,
                                          disabledBackgroundColor:
                                              constants.primary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          elevation: 2,
                                          shadowColor: constants.primary,
                                        ),
                                        child: Text(
                                          "Yes",
                                          style: TextStyle(
                                            color: constants.background,
                                            fontSize: constants.fsLabel,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      // ── Bottom utility group (always visible) ─────────────
                      Column(
                        children: [
                          GestureDetector(
                            child: Row(
                              children: [
                                svgs.icon(
                                  "settings",
                                  constants.darkGrey,
                                  width: 22,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Settings",
                                  style: TextStyle(
                                    fontSize: constants.fsBody,
                                    color: constants.darkGrey,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              sm.checkIfValidToken();
                              nav.toChangeSettingsPage();
                              viewModel.closeDrawer(context);
                            },
                          ),
                          const SizedBox(height: 20),
                          // Red color signals a destructive action
                          GestureDetector(
                            child: Row(
                              children: [
                                svgs.icon("logout", constants.red, width: 20),
                                const SizedBox(width: 14),
                                Text(
                                  "Log out",
                                  style: TextStyle(
                                    fontSize: constants.fsBody,
                                    color: constants.red,
                                    fontWeight: constants.fwSemiBold,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () async {
                              nav.toLogin();
                              viewModel.closeDrawer(context);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
