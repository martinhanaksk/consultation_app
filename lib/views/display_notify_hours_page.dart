// display_notify_hours_page.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Displays and manages the list of notification hours for the current user.

import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/change_settings_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:flutter/material.dart';

class DisplayNotifyHoursPage extends StatefulWidget {
  final ChangeSettingsPageViewModel viewModel;

  const DisplayNotifyHoursPage({super.key, required this.viewModel});

  @override
  State<DisplayNotifyHoursPage> createState() => _DisplayNotifyHoursPageState();
}

class _DisplayNotifyHoursPageState extends State<DisplayNotifyHoursPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constants.background,
      appBar: AppBarMenu(onSettingsPage: true),
      body: SafeArea(
        child: ListenableBuilder(
          // Rebuilds whenever an hour is added or removed in the viewmodel
          listenable: widget.viewModel,
          builder: (context, _) {
            final hours = widget.viewModel.notifyHours;

            return Column(
              children: [
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Text(
                    "Notification hours before each consultation",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: constants.fwSemiBold,
                      fontSize: constants.fsTitle,
                      color: constants.darkGrey,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                if (hours.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        "Turned off",
                        style: TextStyle(
                          fontSize: constants.fsBody,
                          color: constants.darkGrey150,
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        overscroll: false,
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: hours.length,
                        itemBuilder: (context, index) {
                          final h = hours[index];

                          return Container(
                            decoration: constants.squircleShadow(
                              color: constants.background,
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 6.0),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 2.0,
                              ),
                              leading: svgs.icon(
                                'clock',
                                constants.primary,
                                width: constants.fsTitle,
                              ),
                              title: Text(
                                '$h hour${h == 1 ? '' : 's'} before',
                                style: TextStyle(
                                  color: constants.darkGrey,
                                  fontWeight: constants.fwSemiBold,
                                ),
                              ),
                              trailing: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () =>
                                    widget.viewModel.removeNotifyHour(h),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: svgs.icon(
                                    'trash',
                                    constants.red,
                                    width: constants.fsTitle,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
