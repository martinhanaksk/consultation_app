import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class ConsultationTypeToggle extends StatelessWidget {
  final bool isOnlineSelected;
  final bool isOnlineTeacherSelected;
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
