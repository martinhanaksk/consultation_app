import 'package:consultation_app/viewmodels/slider_menu_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SliderMenu extends StatefulWidget {
  const SliderMenu({super.key});

  @override
  State<SliderMenu> createState() => _SliderMenuState();
}

class _SliderMenuState extends State<SliderMenu> {
  late final SliderMenuViewmodel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SliderMenuViewmodel();
    _viewModel.checkSliderMenuFundamentals();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<SliderMenuViewmodel>(
        builder: (context, viewModel, child) {
          return SafeArea(
            child: Drawer(
              backgroundColor: constants.background,
              width: 220,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                              sm.checkIfValidToken();
                              viewModel.isOwner!
                                  ? nav.toOwnerConsultations()
                                  : nav.toBaseConsultations();
                              viewModel.closeDrawer(context);
                            },
                          ),
                        ),

                        const SizedBox(height: 20),
                        GestureDetector(
                          child: Container(
                            child: Text(
                              "Home",
                              style: TextStyle(
                                fontSize: constants.fsBody,
                                color: constants.darkGrey,
                              ),
                            ),
                          ),
                          onTap: () {
                            sm.checkIfValidToken();
                            viewModel.isOwner!
                                ? nav.toOwnerConsultations()
                                : nav.toBaseConsultations();
                            viewModel.closeDrawer(context);
                          },
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          child: Container(
                            child: Text(
                              "Join Room",
                              style: TextStyle(
                                fontSize: constants.fsBody,
                                color: constants.darkGrey,
                              ),
                            ),
                          ),
                          onTap: () {
                            sm.checkIfValidToken();
                            nav.toJoinRoom();
                            viewModel.closeDrawer(context);
                          },
                        ),
                        const SizedBox(height: 20),
                        (viewModel.isOwner != null && viewModel.isOwner!)
                            ? Column(
                                children: [
                                  GestureDetector(
                                    child: Container(
                                      child: Text(
                                        "Create Room",
                                        style: TextStyle(
                                          fontSize: constants.fsBody,
                                          color: constants.darkGrey,
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      nav.toCreateRoom();
                                      viewModel.closeDrawer(context);
                                    },
                                  ),
                                  SizedBox(height: 20),
                                ],
                              )
                            : SizedBox(height: 0),

                        GestureDetector(
                          child: Text(
                            "Provide Feedback",
                            style: TextStyle(
                              fontSize: constants.fsBody,
                              color: constants.darkGrey,
                            ),
                          ),
                          onTap: () {
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
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(
                                          color: constants.primary,
                                        ),
                                      ),
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
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        FocusScope.of(context).unfocus();
                                        viewModel.launchFeedbackWebsite();
                                      },
                                      child: Text(
                                        "Yes",
                                        style: TextStyle(
                                          color: constants.background,
                                        ),
                                      ),
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
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          child: Text(
                            "Settings",
                            style: TextStyle(
                              fontSize: constants.fsBody,
                              color: constants.darkGrey,
                            ),
                          ),

                          onTap: () {
                            nav.toChangeSettings();
                            viewModel.closeDrawer(context);
                          },
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          child: Text(
                            "Log out",
                            style: TextStyle(
                              fontSize: constants.fsBody,
                              color: constants.red,
                              fontWeight: constants.fwSemiBold,
                            ),
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
          );
        },
      ),
    );
  }
}
