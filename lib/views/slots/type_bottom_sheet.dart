// type_bottom_sheet.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Bottom sheet for changing a booked slot's consultation type (online / in-person).
// Accessible to the room owner for any taken slot, and to a student for their own slot.
// The callback is only fired when the value actually changes to avoid redundant API calls.

import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';
import 'keyboard_padding.dart';
import 'type_toggle.dart';

class ConsultationTypeBottomSheet extends StatefulWidget {
  final VoidCallback onChangeConsultationType;
  // API int flags: 1 = online, 0 = in-person
  final int isOnline;
  final int isOnlineTeacher;
  final String name;
  final String reason;
final bool isTeacher;
  const ConsultationTypeBottomSheet({
    super.key,
    required this.onChangeConsultationType,
    required this.isOnline,
    required this.isOnlineTeacher,
    required this.name,
    required this.reason,required this.isTeacher
  });

  @override
  State<ConsultationTypeBottomSheet> createState() =>
      _ConsultationTypeBottomSheetState();
}

class _ConsultationTypeBottomSheetState
    extends State<ConsultationTypeBottomSheet> {
  bool isOnlineSelected = false;
  bool isOnlineTeacherSelected = false;
  // Snapshot of the initial value used to detect whether the user actually changed anything
  bool startingValue = false;

  @override
  void initState() {
    super.initState();
    // Convert the API int flags to bools for the toggle widget
    isOnlineSelected = widget.isOnline == 1;
    isOnlineTeacherSelected = widget.isOnlineTeacher == 1;
    startingValue = isOnlineSelected;
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardPadding(
      child: Container(
        decoration: BoxDecoration(
          color: constants.background,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConsultationTypeToggle(
              isOnlineSelected: isOnlineSelected,
              isOnlineTeacherSelected: isOnlineTeacherSelected,
              name: widget.name,
              reason: widget.reason,
              onChanged: (bool newValue) =>
                  setState(() => isOnlineSelected = newValue),
              isTeacher: widget.isTeacher,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: constants.background),
                      ),
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: constants.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Only invoke the callback when the type actually changed
                      if (startingValue != isOnlineSelected) {
                        widget.onChangeConsultationType();
                      }
                      Navigator.pop(context, isOnlineSelected);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: constants.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Change",
                      style: TextStyle(color: constants.background),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
