// custom_time_duration_picker.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Side-by-side Cupertino picker pair: a slot duration wheel (5–120 min)
// and a 24-hour start-time picker, both snapped to 5-minute intervals.

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:consultation_app/setup.dart';

class CustomTimeDurationPicker extends StatefulWidget {
  final Duration? initialStartTime;
  final Duration? initialDuration;
  final ValueChanged<Duration> onStartTimeChanged;
  final ValueChanged<Duration> onDurationChanged;
  final String durationLabel;
  final String startTimeLabel;
  const CustomTimeDurationPicker({
    super.key,
    required this.onStartTimeChanged,
    required this.onDurationChanged,
    this.initialStartTime,
    this.initialDuration,
    this.durationLabel = 'Minutes per Slot',
    this.startTimeLabel = 'Slot Start Time',
  });
  @override
  State<CustomTimeDurationPicker> createState() => _CustomTimeDurationPickerState();
}

class _CustomTimeDurationPickerState extends State<CustomTimeDurationPicker> {
  late DateTime _currentStart;
  late FixedExtentScrollController _durationController;
  @override
  void initState() {
    super.initState();
    final now = TimeOfDay.now();
    // Round down to the nearest 5-minute mark so the time picker starts on a valid interval
    final rounded = now.minute - (now.minute % 5);

    final start =
        widget.initialStartTime ?? Duration(hours: now.hour, minutes: rounded);
    // CupertinoDatePicker requires a full DateTime; the date part (2000-01-01) is irrelevant here
    _currentStart = DateTime(2000, 1, 1, start.inHours, start.inMinutes % 60);

    final initDuration = widget.initialDuration ?? const Duration(minutes: 15);
    // Index 2 corresponds to 15 min ((2+1)*5); adjust if the default duration changes
    _durationController = FixedExtentScrollController(initialItem: 2);

    // Notify the parent of the resolved initial values after the first frame,
    // so any dependent state is set even when the user never moves the pickers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onStartTimeChanged(start);
      widget.onDurationChanged(initDuration);
    });
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 8,
          child: Column(
            children: [
              Text(
                widget.durationLabel,
                style: TextStyle(
                  fontSize: constants.fsLabel,
                  fontWeight: constants.fwSemiBold,
                  color: constants.darkGrey,
                ),
              ),
              SizedBox(
                height: 150,
                child: CupertinoPicker(
                  backgroundColor: constants.background,
                  itemExtent: 40,
                  scrollController: _durationController,
                  onSelectedItemChanged: (index) {
                    // index 0 → 5 min, index 1 → 10 min, …, index 23 → 120 min
                    widget.onDurationChanged(
                      Duration(minutes: (index + 1) * 5),
                    );
                  },
                  children: List.generate(
                    24,
                    (i) => Center(
                      child: Text(
                        '${(i + 1) * 5} min',
                        style: TextStyle(
                          fontSize: constants.fsBody,
                          color: constants.darkGrey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Spacer between the two pickers
        const Flexible(flex: 1, child: SizedBox()),
        // ── Start-time picker (24 h, 5-min steps) ────────────────────────
        Flexible(
          flex: 10,
          child: Column(
            children: [
              Text(
                widget.startTimeLabel,
                style: TextStyle(
                  fontSize: constants.fsLabel,
                  fontWeight: constants.fwSemiBold,
                  color: constants.darkGrey,
                ),
              ),
              SizedBox(
                height: 150,
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        color: constants.darkGrey,
                        fontSize: constants.fsTitle,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    backgroundColor: constants.background,
                    mode: CupertinoDatePickerMode.time,
                    use24hFormat: true,
                    initialDateTime: _currentStart,
                    minuteInterval: 5,
                    onDateTimeChanged: (dt) {
                      _currentStart = dt;
                      widget.onStartTimeChanged(
                        Duration(hours: dt.hour, minutes: dt.minute),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
