// type_toggle_widget.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Two-button toggle for selecting consultation type (In-Person / Online).
// Used in both TakeSlotBottomSheet and ConsultationTypeBottomSheet.
// The effective selection differs by role: teachers control the toggle freely,
// while students are forced online when the teacher has set isOnlineTeacher = true.

import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class ConsultationTypeToggle extends StatelessWidget {
  // Student-facing online flag (the slot's current type)
  final bool isOnlineSelected;
  // Teacher's own online preference; overrides the student's choice when true
  final bool isOnlineTeacherSelected;
  // Occupant's name; displayed only when non-empty (owner view)
  final String name;
  final ValueChanged<bool> onChanged;

  const ConsultationTypeToggle({
    super.key,
    required this.isOnlineSelected,
    required this.isOnlineTeacherSelected,
    required this.name,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Teachers can set online/offline, while students are locked to online
    // if the teacher has set to online
    final bool effectivelyOnline = sm.role == "teacher"
        ? isOnlineSelected
        : isOnlineTeacherSelected
            ? true
            : isOnlineSelected;

    return Column(
      children: [
        Text(
          "Change Consultation type",
          style: TextStyle(
            fontSize: constants.fsTitle,
            fontWeight: constants.fwSemiBold,
            color: constants.darkGrey,
          ),
        ),
        // Occupant name is only shown when the viewer has visibility enabled
        // and the sheet is opened from the owner view
        if (name.isNotEmpty) ...[
          const SizedBox(height: 20),
          RichText(
            text: TextSpan(
              text: 'Reserved by: ',
              children: [
                TextSpan(
                  text: name,
                  style: TextStyle(
                    fontSize: constants.fsBody,
                    fontWeight: constants.fwSemiBold,
                    color: constants.primary,
                  ),
                ),
              ],
              style: TextStyle(
                fontSize: constants.fsBody,
                fontWeight: constants.fwRegular,
                color: constants.darkGrey,
              ),
            ),
          ),
        ],
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => onChanged(false),
                // Active button uses darkGrey200 background; inactive uses plain background
                style: ElevatedButton.styleFrom(
                  backgroundColor: effectivelyOnline
                      ? constants.background
                      : constants.darkGrey200,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: constants.background),
                  ),
                  elevation: 0,
                ),
                child: Column(
                  children: [
                    svgs.icon(
                      "location",
                      effectivelyOnline
                          ? constants.darkGrey150
                          : constants.background,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "In-Person",
                      style: TextStyle(
                        color: effectivelyOnline
                            ? constants.darkGrey150
                            : constants.background,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => onChanged(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: effectivelyOnline
                      ? constants.darkGrey200
                      : constants.background,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: constants.background),
                  ),
                  elevation: 0,
                ),
                child: Column(
                  children: [
                    svgs.icon(
                      "screen",
                      effectivelyOnline
                          ? constants.background
                          : constants.darkGrey150,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Online",
                      style: TextStyle(
                        color: effectivelyOnline
                            ? constants.background
                            : constants.darkGrey150,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
