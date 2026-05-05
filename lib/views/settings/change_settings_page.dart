// change_settings_page.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Settings screen
// Responsible only for layout and section structure; all tile widgets live in
// settings_tiles.dart and all dialogs live in settings_dialogs.dart.

import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/change_settings_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:consultation_app/views/settings/settings_dialogs.dart';
import 'package:consultation_app/views/settings/settings_tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class ChangeSettings extends StatelessWidget {
  const ChangeSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Cascade calls initialize() immediately after construction
      create: (_) => ChangeSettingsViewmodel()..initialize(),
      child: Consumer<ChangeSettingsViewmodel>(
        builder: (context, viewModel, _) => Scaffold(
          appBar: AppBarMenu(onSettingsPage: true),
          drawer: SliderMenu(),
          backgroundColor: constants.background,
          body: SafeArea(
            child: viewModel.isLoading
                ? Center(
                    child: SpinKitPouringHourGlass(
                      color: constants.primary,
                      size: constants.fsHeadline,
                    ),
                  )
                : _SettingsBody(viewModel: viewModel),
          ),
        ),
      ),
    );
  }
}

// Extracted into its own widget to keep ChangeSettings clean
class _SettingsBody extends StatelessWidget {
  final ChangeSettingsViewmodel viewModel;

  const _SettingsBody({required this.viewModel});

  // Inset divider used between tiles inside a card
  static Widget _divider() => Divider(
        indent: 20,
        endIndent: 20,
        color: constants.darkGrey30,
        height: 1,
      );

  // Full-width divider used below a section header inside a card
  static Widget _sectionDivider() =>
      Divider(color: constants.darkGrey30, height: 1);

  static Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Text(
          title,
          style: TextStyle(
            fontSize: constants.fsLabel,
            fontWeight: constants.fwSemiBold,
            color: constants.darkGrey,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Settings",
            style: TextStyle(
              fontSize: constants.fsHeadline,
              fontWeight: constants.fwSemiBold,
              color: constants.darkGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "View your profile and manage preferences",
            style: TextStyle(
                fontSize: constants.fsLabel, color: constants.darkGrey150),
          ),
          const SizedBox(height: 28),

          // ── Profile card ──────────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: constants.squircleShadow(
                hasBorder: true, color: constants.background),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoTile(
                    svgName: 'person', label: "Email", value: viewModel.email),
                _divider(),
                EditableTile(
                  svgName: 'id',
                  label: "Name",
                  value: '${viewModel.name} ${viewModel.surname}',
                  onEdit: () => showNameDialog(context, viewModel),
                ),
                _divider(),
                EditableTile(
                  svgName: 'pencil',
                  label: "Visit Reason",
                  value: viewModel.visitReason,
                  onEdit: () => showVisitReasonDialog(context, viewModel),
                ),
                _divider(),
                InfoTile(
                    svgName: 'work', label: "Role", value: viewModel.role),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Preferences card ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: constants.squircleShadow(
                hasBorder: true, color: constants.background),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader("Preferences"),
                _sectionDivider(),
                // Icon toggles between eye_open/eye_closed to reflect current state
                CheckboxTile(
                  svgName: viewModel.visibility ? 'eye_open' : 'eye_closed',
                  title: "Visibility",
                  subtitle: "Show your name to others",
                  value: viewModel.visibility,
                  onChanged: (_) => viewModel.setVisibility(),
                ),
                NotifyHoursTile(viewModel: viewModel),
                // Icon toggles between moon/sun to reflect the active theme
                CheckboxTile(
                  svgName: themeSelector.isDark ? 'moon' : 'sun',
                  title: "Theme",
                  subtitle: "Switch to dark appearance",
                  value: themeSelector.isDark,
                  onChanged: viewModel.setTheme,
                ),
              ],
            ),
          ),

          // ── Administration card (teachers only) ───────────────────────────
          if (viewModel.role == 'teacher') ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: constants.squircleShadow(
                  hasBorder: true, color: constants.background),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader("Administration"),
                  _sectionDivider(),
                  ActionTile(
                    svgName: 'person',
                    title: "Create Teacher",
                    subtitle: "Register a new teacher account.",
                    onTap: () => showCreateTeacherDialog(context, viewModel),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
