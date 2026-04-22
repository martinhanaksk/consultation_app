import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/change_settings_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ChangeSettings extends StatefulWidget {
  const ChangeSettings({super.key});

  @override
  State<ChangeSettings> createState() => _ChangeSettingsState();
}

class _ChangeSettingsState extends State<ChangeSettings> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = ChangeSettingsViewmodel();
        viewModel.initialize();
        return viewModel;
      },
      child: Consumer<ChangeSettingsViewmodel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBarMenu(),
            drawer: SliderMenu(),
            backgroundColor: constants.background,
            body: SafeArea(
              child: viewModel.email == ""
                  ? Center(
                      child: SpinKitPouringHourGlass(
                        color: constants.primary,
                        size: constants.fsHeadline,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Text(
                            "Account Settings",
                            style: TextStyle(
                              fontSize: constants.fsHeadline,
                              fontWeight: constants.fwSemiBold,
                              color: constants.darkGrey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Manage your profile and preferences",
                            style: TextStyle(
                              fontSize: constants.fsLabel,
                              color: constants.darkGrey150,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Profile Card
                          Container(
                            width: double.infinity,
                            decoration: constants.squircleShadow(
                              color: constants.background,
                              borderRadius: SmoothBorderRadius(
                                cornerRadius: 12,
                                cornerSmoothing: 0.6,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Info Rows
                                _InfoTile(
                                  svgName: 'person',
                                  label: "Email",
                                  value: viewModel.email,
                                ),
                                Divider(
                                  indent: 20,
                                  endIndent: 20,
                                  color: constants.darkGrey30,
                                  height: 1,
                                ),
                                _InfoTile(
                                  svgName: 'id',
                                  label: "Name",
                                  value:
                                      '${viewModel.name} ${viewModel.surname}',
                                ),
                                Divider(
                                  indent: 20,
                                  endIndent: 20,
                                  color: constants.darkGrey30,
                                  height: 1,
                                ),
                                _InfoTile(
                                  svgName: 'work',
                                  label: "Role",
                                  value: viewModel.role,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Preferences Card
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: constants.background,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: constants.darkGrey30,
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    16,
                                    20,
                                    8,
                                  ),
                                  child: Text(
                                    "Preferences",
                                    style: TextStyle(
                                      fontSize: constants.fsLabel,
                                      fontWeight: constants.fwSemiBold,
                                      color: constants.darkGrey,
                                    ),
                                  ),
                                ),
                                Divider(color: constants.darkGrey30, height: 1),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 14,
                                  ),
                                  child: Row(
                                    children: [
                                      viewModel.visibility
                                          ? svgs.icon(
                                              'eye_open',constants.primary,
                                              width: constants.fsTitle,
                                             
                                            )
                                          : svgs.icon(
                                              'eye_closed',constants.primary,
                                              width: constants.fsTitle,
                                              

                                            ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Visibility",
                                              style: TextStyle(
                                                fontSize: constants.fsBody,
                                                fontWeight:
                                                    constants.fwSemiBold,
                                                color: constants.darkGrey,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Show your name to others.",
                                              style: TextStyle(
                                                fontSize: constants.fsLabel,
                                                color: constants.darkGrey150,fontWeight: constants.fwRegular
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Checkbox(
                                        value: viewModel.visibility,
                                        activeColor: constants.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        onChanged: (val) {
                                          viewModel.setVisibility();
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 14,
                                  ),
                                  child: Row(
                                    children: [
                                      viewModel.receiveEmails
                                          ? svgs.icon(
                                              'bell_ringing',constants.primary,
                                              width: constants.fsTitle,
                                              
                                            )
                                          : svgs.icon(
                                              'bell_crossed',constants.primary,
                                              width: constants.fsTitle,
                                            
                                            ),

                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Receive Emails",
                                              style: TextStyle(
                                                fontSize: constants.fsBody,
                                                fontWeight:
                                                    constants.fwSemiBold,
                                                color: constants.darkGrey,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Get emails about changes in selected consultation blocks",
                                              style: TextStyle(
                                                fontSize: constants.fsLabel,
                                                color: constants.darkGrey150,fontWeight: constants.fwRegular
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Checkbox(
                                        value: viewModel.receiveEmails,
                                        activeColor: constants.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        onChanged: (val) {
                                          viewModel.setReceiveEmail(val);
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 14,
                                  ),
                                  child: Row(
                                    children: [
                                      themeSelector.isDark
                                          ? svgs.icon(
                                              'moon',constants.primary,
                                              width: constants.fsTitle,
                                              
                                            )
                                          : svgs.icon(
                                              'sun',constants.primary,
                                              width: constants.fsTitle,
                                            
                                            ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Dark Mode",
                                              style: TextStyle(
                                                fontSize: constants.fsBody,
                                                fontWeight:
                                                    constants.fwSemiBold,
                                                color: constants.darkGrey,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Switch to dark appearance.",
                                              style: TextStyle(
                                                fontSize: constants.fsLabel,
                                                color: constants.darkGrey150,fontWeight: constants.fwRegular
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Checkbox(
                                        value: themeSelector.isDark,
                                        activeColor: constants.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        onChanged: (val) async {
                                          viewModel.setTheme(val);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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

class _InfoTile extends StatelessWidget {
  final String svgName;
  final String label;
  final String value;

  const _InfoTile({
    required this.svgName,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          svgs.icon(
            svgName,constants.primary,
            width: constants.fsTitle,
            
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: constants.fsLabel,
                    color: constants.darkGrey150,fontWeight: constants.fwRegular
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: constants.fsBody,
                    fontWeight: constants.fwSemiBold,
                    color: constants.darkGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
