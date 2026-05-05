import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class SlotTime extends StatelessWidget {
  final String time;
  final Color color;

  const SlotTime({super.key, required this.time, required this.color});

  @override
  Widget build(BuildContext context) {
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
