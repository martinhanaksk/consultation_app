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
                              color: constants.grey,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Profile Card
                          Container(
                            width: double.infinity,
                            decoration: constants.figmaLightShadowWith(
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
                                  icon: Icons.person_2_outlined,
                                  label: "Email",
                                  value: viewModel.email,
                                ),
                                Divider(
                                  indent: 20,
                                  endIndent: 20,
                                  color: constants.darkGrey.withValues(
                                    alpha: 0.08,
                                  ),
                                  height: 1,
                                ),
                                _InfoTile(
                                  icon: Icons.badge_outlined,
                                  label: "Name",
                                  value:
                                      '${viewModel.name} ${viewModel.surname}',
                                ),
                                Divider(
                                  indent: 20,
                                  endIndent: 20,
                                  color: constants.darkGrey.withValues(
                                    alpha: 0.08,
                                  ),
                                  height: 1,
                                ),
                                _InfoTile(
                                  icon: Icons.work_outline_rounded,
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
                                  color: constants.darkGrey.withValues(
                                    alpha: 0.06,
                                  ),
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
                                Divider(
                                  color: constants.darkGrey.withValues(
                                    alpha: 0.08,
                                  ),
                                  height: 1,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    viewModel.setReceiveEmail(
                                      !viewModel.receiveEmails,
                                    );
                                  },

                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 14,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.email_outlined,
                                          color: constants.primary,
                                          size: constants.fsBody,
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
                                                  color: constants.darkGrey
                                                      .withValues(alpha: 0.55),
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
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: constants.primary, size: constants.fsBody),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: constants.fsLabel,
                  color: constants.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: constants.fsBody,
                  fontWeight: constants.fwSemiBold,
                  color: constants.darkGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
