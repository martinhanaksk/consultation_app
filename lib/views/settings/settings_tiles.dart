// settings_tiles.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// All list-tile widgets used on the settings page.
// Tiles are stateless except for NotifyHoursTile, which manages its own
// text field and inline validation state.

import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/change_settings_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/custom_checkbox_widget.dart';
import 'package:consultation_app/views/custom_widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';

// Read-only profile field: label above, bold value below
class InfoTile extends StatelessWidget {
  final String svgName;
  final String label;
  final String value;

  const InfoTile({
    super.key,
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
          svgs.icon(svgName, constants.primary, width: constants.fsTitle),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: constants.fsLabel,
                    color: constants.darkGrey150,
                    fontWeight: constants.fwRegular,
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

// Profile field with a trailing edit icon that opens a dialog via onEdit
class EditableTile extends StatelessWidget {
  final String svgName;
  final String label;
  final String value;
  final VoidCallback onEdit;

  const EditableTile({
    super.key,
    required this.svgName,
    required this.label,
    required this.value,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          svgs.icon(svgName, constants.primary, width: constants.fsTitle),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: constants.fsLabel,
                    color: constants.darkGrey150,
                    fontWeight: constants.fwRegular,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 2,
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
          IconButton(
            onPressed: onEdit,
            icon: svgs.icon('edit', constants.primary, width: constants.fsBody),
            tooltip: "Edit",
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

// Tappable row with a trailing arrow
class ActionTile extends StatelessWidget {
  final String svgName;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ActionTile({
    super.key,
    required this.svgName,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            svgs.icon(svgName, constants.primary, width: constants.fsTitle),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: constants.fsBody,
                      fontWeight: constants.fwSemiBold,
                      color: constants.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: constants.fsLabel,
                      color: constants.darkGrey150,
                      fontWeight: constants.fwRegular,
                    ),
                  ),
                ],
              ),
            ),
            svgs.icon(
              'arrow_right',
              constants.darkGrey150,
              width: constants.fsBody,
            ),
          ],
        ),
      ),
    );
  }
}

// Preference row with a trailing checkbox; the caller controls the icon to
// reflect the current state (e.g. eye_open/eye_closed, moon/sun)
class CheckboxTile extends StatelessWidget {
  final String svgName;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const CheckboxTile({
    super.key,
    required this.svgName,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          svgs.icon(svgName, constants.primary, width: constants.fsTitle),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: constants.fsBody,
                    fontWeight: constants.fwSemiBold,
                    color: constants.darkGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: constants.fsLabel,
                    color: constants.darkGrey150,
                    fontWeight: constants.fwRegular,
                  ),
                ),
              ],
            ),
          ),
          CustomCheckbox(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

// Inline editable tile for notification time (hours before a consultation).
// StatefulWidget because the text field is self-contained here
class NotifyHoursTile extends StatefulWidget {
  final ChangeSettingsViewmodel viewModel;

  const NotifyHoursTile({super.key, required this.viewModel});

  @override
  State<NotifyHoursTile> createState() => _NotifyHoursTileState();
}

class _NotifyHoursTileState extends State<NotifyHoursTile> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.viewModel.notifyHoursBefore.toString(),
    );
  }

  // Keeps the field in sync if the viewmodel value changes externally
  // (e.g. after a successful save resets it from the server response)
  @override
  void didUpdateWidget(NotifyHoursTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newValue = widget.viewModel.notifyHoursBefore.toString();
    if (_ctrl.text != newValue) _ctrl.text = newValue;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // Updates the viewmodel on input
  void _onChanged(String val) {
    final parsed = int.tryParse(val);
    if (parsed != null) {
      widget.viewModel.updateNotifyHoursBefore(parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          _ctrl.text == "0"
              ? svgs.icon(
                  'clock_crossed',
                  constants.primary,
                  width: constants.fsTitle,
                )
              : svgs.icon('clock', constants.primary, width: constants.fsTitle),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Notify me before",
                  style: TextStyle(
                    fontSize: constants.fsBody,
                    fontWeight: constants.fwSemiBold,
                    color: constants.darkGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "How early to receive a consultation reminder",
                  style: TextStyle(
                    fontSize: constants.fsLabel,
                    color: constants.darkGrey150,
                    fontWeight: constants.fwRegular,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: CustomInputTextField(
              controller: _ctrl,
              maxLength: 3,
              keyboardType: TextInputType.number,
              onChanged: _onChanged,
              textColor: constants.primary,
              suffixText: "h",
              textCenter: true,
              showClearIcon: false,
              suffixStyle: TextStyle(
                fontSize: constants.fsLabel,
                color: constants.darkGrey150,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
