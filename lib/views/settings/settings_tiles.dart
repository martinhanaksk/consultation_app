// settings_tiles.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// All list-tile widgets used on the settings page.
// Tiles are stateless except for NotifyHoursTile, which manages its own
// text field and inline validation state.

import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/change_settings_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/custom_checkbox_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

// Inline add tile for notification hours.
// Mirrors _EmailDomainField + _ViewDomainsLink from room_form_body.dart.
class NotifyHoursTile extends StatefulWidget {
  final ChangeSettingsPageViewModel viewModel;

  const NotifyHoursTile({super.key, required this.viewModel});

  @override
  State<NotifyHoursTile> createState() => _NotifyHoursTileState();
}

class _NotifyHoursTileState extends State<NotifyHoursTile> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _add() {
    final parsed = int.tryParse(_ctrl.text.trim());
    if (parsed == null || parsed <= 0) return;
    widget.viewModel.addNotifyHour(parsed);
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.viewModel.notifyHours.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────────────────────────
          Row(
            children: [
              svgs.icon(
                count == 0
                    ? 'notifications_bell_empty'
                    : 'notifications_bell_full',
                constants.primary,
                width: constants.fsTitle,
              ),
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
                      "Hours before a consultation to receive a reminder",
                      style: TextStyle(
                        fontSize: constants.fsLabel,
                        color: constants.darkGrey150,
                        fontWeight: constants.fwRegular,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // ── Input row ───────────────────────────────────────────────────
          TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            maxLength: 3,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(color: constants.darkGrey),
            decoration: InputDecoration(
              counterText: '',
              hintText: 'Hours (e.g. 24)',
              border: _border(constants.grey),
              enabledBorder: _border(constants.grey),
              focusedBorder: _border(constants.primary, width: 1.5),
              suffixText: 'h',
              suffixStyle: TextStyle(
                fontSize: constants.fsLabel,
                color: constants.darkGrey150,
              ),
              suffixIcon: GestureDetector(
                onTap: _add,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: svgs.icon(
                    'add',
                    constants.primary,
                    width: constants.fsBody,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // ── View list link ──────────────────────────────────────────────
          GestureDetector(
            onTap: () => nav.toDisplayNotifyHours(viewModel: widget.viewModel),
            child: Text(
              'View added hours ($count)',
              style: TextStyle(
                color: constants.primary,
                fontSize: constants.fsLabel,
                fontWeight: constants.fwSemiBold,
                decoration: TextDecoration.underline,
                decorationColor: constants.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1.0}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
}
