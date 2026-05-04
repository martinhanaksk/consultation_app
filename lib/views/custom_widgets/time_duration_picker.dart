import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:consultation_app/setup.dart';

class TimeDurationPicker extends StatefulWidget {
  final Duration? initialStartTime;
  final Duration? initialDuration;
  final ValueChanged<Duration> onStartTimeChanged;
  final ValueChanged<Duration> onDurationChanged;
  final String durationLabel;
  final String startTimeLabel;

  const TimeDurationPicker({
    super.key,
    required this.onStartTimeChanged,
    required this.onDurationChanged,
    this.initialStartTime,
    this.initialDuration,
    this.durationLabel = 'Minutes per Slot',
    this.startTimeLabel = 'Slot Start Time',
  });

  @override
  State<TimeDurationPicker> createState() => _TimeDurationPickerState();
}

class _TimeDurationPickerState extends State<TimeDurationPicker> {
  late DateTime _currentStart;
  late FixedExtentScrollController _durationController;

  @override
  void initState() {
    super.initState();
    final now = TimeOfDay.now();
    final rounded = now.minute - (now.minute % 5);

    final start = widget.initialStartTime ??
        Duration(hours: now.hour, minutes: rounded);
    _currentStart = DateTime(2000, 1, 1, start.inHours, start.inMinutes % 60);

    final initDuration = widget.initialDuration ?? const Duration(minutes: 15);
    _durationController = FixedExtentScrollController(
      initialItem:3,
    );

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
        const Flexible(flex: 1, child: SizedBox()),
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
