// slot_time_widget.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Displays a fixed-width HH:mm time label used consistently across all slot widgets
// (FreeSlot, CurrentUserSlot, AnotherUsersSlot).

import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class SlotTime extends StatelessWidget {
  final String time;
  final Color color;

  const SlotTime({super.key, required this.time, required this.color});

  @override
  Widget build(BuildContext context) {
    // The time string from the API includes seconds (HH:mm:ss),
    // however only the first two parts are displayed
    final parts = time.split(":");
    return SizedBox(
      width: 56,
      child: Text(
        '${parts[0]}:${parts[1]}',
        textAlign: TextAlign.right,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: constants.fsLabel,
          fontWeight: constants.fwRegular,
        ),
      ),
    );
  }
}
