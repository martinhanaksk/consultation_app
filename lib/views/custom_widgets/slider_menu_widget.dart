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
                              helpers.checkIfValidToken(viewModel.token);
                              viewModel.isOwner!
                                  ? nav.toOwnerConsultations(
                                      token: viewModel.token,
                                      email: viewModel.email!,
                                    )
                                  : nav.toBaseConsultations(
                                      token: viewModel.token,
                                      email: viewModel.email!,
                                    );
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
                            helpers.checkIfValidToken(viewModel.token);
                            viewModel.isOwner!
                                ? nav.toOwnerConsultations(
                                    token: viewModel.token,
                                    email: viewModel.email!,
                                  )
                                : nav.toBaseConsultations(
                                    token: viewModel.token,
                                    email: viewModel.email!,
                                  );
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
                            helpers.checkIfValidToken(viewModel.token);
                            nav.toJoinRoom(token: viewModel.token);
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
                                    GestureDetector(
                                      onTap: () {
                                        nav.pop();
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: constants.squircleShadow(
                                          color: constants.background,
                                        ),
                                        child: Text(
                                          "Cancel",
                                          style: TextStyle(
                                            color: constants.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        viewModel.launchFeedbackWebsite();
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: constants.squircleShadow(
                                          color: constants.background,
                                        ),
                                        child: Text(
                                          "Yes",
                                          style: TextStyle(
                                            color: constants.primary,
                                          ),
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
                            
                            // Navigate to login and clear all previous routes
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
