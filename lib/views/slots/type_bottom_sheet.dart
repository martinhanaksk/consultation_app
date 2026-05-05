import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';
import 'keyboard_padding.dart';
import 'type_toggle.dart';

class ConsultationTypeBottomSheet extends StatefulWidget {
  final VoidCallback onChangeConsultationType;
  final int isOnline;
  final int isOnlineTeacher;
  final String name;

  const ConsultationTypeBottomSheet({
    super.key,
    required this.onChangeConsultationType,
    required this.isOnline,
    required this.isOnlineTeacher,
    required this.name,
  });

  @override
  State<ConsultationTypeBottomSheet> createState() =>
      _ConsultationTypeBottomSheetState();
}

class _ConsultationTypeBottomSheetState
    extends State<ConsultationTypeBottomSheet> {
  bool isOnlineSelected = false;
  bool isOnlineTeacherSelected = false;
  bool startingValue = false;

  @override
  void initState() {
    super.initState();
    isOnlineSelected = widget.isOnline == 1;
    isOnlineTeacherSelected = widget.isOnlineTeacher == 1;
    startingValue = isOnlineSelected;
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardPadding(
      child: Container(
        decoration: constants.squircleShadow(
          color: constants.background,
          hasBorder: false,
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
              onChanged: (bool newValue) =>
                  setState(() => isOnlineSelected = newValue),
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
