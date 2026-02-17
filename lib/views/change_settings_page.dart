import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/change_settings_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangeSettings extends StatefulWidget {
  const ChangeSettings({super.key});

  @override
  State<ChangeSettings> createState() => _ChangeSettingsState();
}

class _ChangeSettingsState extends State<ChangeSettings> {
  @override
  void initState() {
    super.initState();
  }

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
            backgroundColor: constants.bgLight,
            body: SafeArea(
              child: viewModel.email == ""
                  ? Center(
                      child: CircularProgressIndicator(
                        color: constants.primaryColor,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Align(
                        child: Column(
                          children: [
                            Text(
                              "Email: ${viewModel.email}",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: constants.fontSizeSmall,
                                fontWeight: FontWeight.w500,
                                color: constants.defaultDarkGrey,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              "Name: ${viewModel.name}",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: constants.fontSizeSmall,
                                fontWeight: FontWeight.w500,
                                color: constants.defaultDarkGrey,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              "Role: ${viewModel.role}",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: constants.fontSizeSmall,
                                fontWeight: FontWeight.w500,
                                color: constants.defaultDarkGrey,
                              ),
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
