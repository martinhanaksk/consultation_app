import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/create_block_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter/cupertino.dart';

class CreateBlock extends StatefulWidget {
  final String token;
  final String roomId;
  final VoidCallback? onSuccess;
  const CreateBlock({
    super.key,
    required this.token,
    required this.roomId,
    required this.onSuccess,
  });

  @override
  State<CreateBlock> createState() => _CreateBlockState();
}

class _CreateBlockState extends State<CreateBlock> {
  late final CreateBlockViewmodel _viewModel;
  @override
  void initState() {
    super.initState();
    _viewModel = CreateBlockViewmodel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _showDatePickerDialog(
    BuildContext context,
    CreateBlockViewmodel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            return AlertDialog(
              backgroundColor: constants.background,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Dates',
                    style: TextStyle(
                      color: constants.darkGrey,
                      fontWeight: constants.fwSemiBold,
                      fontSize: constants.fsTitle,
                    ),
                  ),
                  Container(
                    color: constants.background,
                    child: PopupMenuButton<dynamic>(
                      position: PopupMenuPosition.under,
                      offset: const Offset(0, 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: constants.background,
                      elevation: 12,
                      shadowColor: constants.darkGrey.withValues(alpha: 0.12),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: constants.squircleShadow(
                          color: constants.background,
                        ),
                        child: Text(
                          "${viewModel.selectionMode.name[0].toUpperCase()}${viewModel.selectionMode.name.substring(1).toLowerCase()}",
                          style: TextStyle(
                            color: constants.darkGrey,
                            fontWeight: constants.fwSemiBold,
                            fontSize: constants.fsLabel,
                          ),
                        ),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem<dynamic>(
                          value: DateRangePickerSelectionMode.multiple,
                          child: Text(
                            'Multiple',
                            style: TextStyle(
                              color: constants.darkGrey,
                              fontWeight: constants.fwSemiBold,
                              fontSize: constants.fsLabel,
                            ),
                          ),
                        ),
                        PopupMenuItem<dynamic>(
                          value: DateRangePickerSelectionMode.range,
                          child: Text(
                            'Range',
                            style: TextStyle(
                              color: constants.darkGrey,
                              fontWeight: constants.fwSemiBold,
                              fontSize: constants.fsLabel,
                            ),
                          ),
                        ),
                      ],
                      onSelected: (mode) {
                        if (mode != null) {
                          viewModel.setSelectedDates(null);
                          viewModel.setSelectionMode(mode);
                        }
                      },
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                height: 320,
                width: double.maxFinite,

                child: SfDateRangePicker(
                  headerStyle: DateRangePickerHeaderStyle(
                    backgroundColor: constants.background,
                    textStyle: TextStyle(
                      color: constants.primary,
                      fontWeight: constants.fwSemiBold,
                      fontSize: constants.fsBody,
                    ),
                  ),
                  backgroundColor: constants.background,
                  selectionColor: constants.primary,
                  rangeSelectionColor: constants.lightPrimary,
                  todayHighlightColor: constants.lightPrimary,
                  startRangeSelectionColor: constants.primary,
                  endRangeSelectionColor: constants.primary,
                  view: DateRangePickerView.month,
                  selectionMode: viewModel.selectionMode,
                  initialSelectedDates:
                      viewModel.selectionMode ==
                          DateRangePickerSelectionMode.multiple
                      ? viewModel.selectedDates
                      : null,
                  initialSelectedRange:
                      viewModel.selectionMode ==
                          DateRangePickerSelectionMode.range
                      ? viewModel.selectedDates
                      : null,
                  onSelectionChanged:
                      (DateRangePickerSelectionChangedArgs args) {
                        viewModel.setSelectedDates(args.value);
                      },
                ),
              ),
              actions: [
                GestureDetector(
                  onTap: () => {
                    Navigator.pop(context),
                    viewModel.setSelectedDates(null),
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: constants.primary,
                      fontWeight: constants.fwRegular,
                      fontSize: constants.fsLabel,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: constants.squircleShadow(
                      color: constants.primary,
                    ),
                    child: Text(
                      'Confirm',
                      style: TextStyle(
                        color: constants.background,
                        fontWeight: constants.fwRegular,
                        fontSize: constants.fsLabel,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,

      child: Consumer<CreateBlockViewmodel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBarMenu(),
            drawer: SliderMenu(),
            backgroundColor: constants.background,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Text(
                          'Create block',
                          style: TextStyle(
                            color: constants.darkGrey,
                            fontWeight: constants.fwSemiBold,
                            fontSize: constants.fsHeadline,
                          ),
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: () =>
                              _showDatePickerDialog(context, viewModel),
                          child: Container(
                            height: 56,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: constants.squircleShadow(
                              color: constants.background,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Selected: ' +
                                      viewModel.getSelectedDatesFormatted(),
                                  style: TextStyle(fontSize: constants.fsLabel),
                                ),
                                Icon(Icons.calendar_today),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 8,
                              child: Column(
                                children: [
                                  Text(
                                    "Minutes per Slot",
                                    style: TextStyle(
                                      fontSize: constants.fsLabel,
                                      fontWeight: constants.fwSemiBold,
                                      color: constants.darkGrey,
                                    ),
                                  ),
                                  _DurationPicker(viewModel: viewModel),
                                ],
                              ),
                            ),
                            Flexible(flex: 1, child: SizedBox()),
                            Flexible(
                              flex: 10,
                              child: Column(
                                children: [
                                  Text(
                                    "Block Start Time",
                                    style: TextStyle(
                                      fontSize: constants.fsLabel,
                                      fontWeight: constants.fwSemiBold,
                                      color: constants.darkGrey,
                                    ),
                                  ),
                                  _StartTimePicker(viewModel: viewModel),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 5,
                              child: Container(
                                clipBehavior: Clip.none,
                                decoration: constants.squircleShadow(
                                  color: constants.background,
                                ),
                                child: TextField(
                                  scrollPadding: EdgeInsets.only(bottom: 1000),
                                  controller: viewModel.slotNumberController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                    ),

                                    hintText: 'Slots',
                                  ),
                                ),
                              ),
                            ),
                            Flexible(flex: 1, child: SizedBox()),
                            Flexible(
                              flex: 10,
                              child: Opacity(
                                opacity: 0.5,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  decoration: constants.squircleShadow(
                                    color: constants.background,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        viewModel.endTime == null
                                            ? 'End Time'
                                            : "End Time ${viewModel.getPrintableTimeFormat(TimePickerAction.endTime)}",

                                        style: TextStyle(
                                          fontSize: constants.fsBody,
                                        ),
                                      ),
                                      const Icon(Icons.access_time, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),
                        Container(
                          clipBehavior: Clip.none,
                          decoration: constants.squircleShadow(
                            color: constants.background,
                          ),
                          child: TextField(
                            scrollPadding: EdgeInsets.only(bottom: 1000),
                            controller: viewModel.noteController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              hintText: 'Note',
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            IntrinsicWidth(
                              child: Container(
                                width: 24,
                                height: 24,
                                clipBehavior: Clip.none,
                                decoration: constants.squircleShadow(
                                  color: constants.background,
                                ),
                                child: Checkbox(
                                  value: viewModel.isChecked,
                                  onChanged: viewModel.toggleisOnline,
                                  side: BorderSide.none,
                                  checkColor: constants.darkGrey,
                                  fillColor: WidgetStateProperty.all(
                                    constants.background,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            const Text('Online'),
                          ],
                        ),
                        SizedBox(height: 20),
                        viewModel.isLoading
                            ? Center(
                                child: SpinKitPouringHourGlass(
                                  color: constants.primary,
                                  size: constants.fsHeadline,
                                ),
                              )
                            : SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () => {
                                    viewModel.createBlock(
                                      widget.token,
                                      widget.roomId,
                                      widget.onSuccess,
                                    ),
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: constants.primary,
                                    disabledBackgroundColor: constants.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 2,
                                    shadowColor: constants.primary,
                                  ),
                                  child: Text(
                                    'Create',
                                    style: TextStyle(
                                      fontSize: constants.fsBody,
                                      fontWeight: constants.fwSemiBold,
                                      color: constants.background,
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StartTimePicker extends StatefulWidget {
  final CreateBlockViewmodel viewModel;
  const _StartTimePicker({required this.viewModel});

  @override
  State<_StartTimePicker> createState() => _StartTimePickerState();
}

class _StartTimePickerState extends State<_StartTimePicker> {
  late DateTime _current;

  @override
  void initState() {
    super.initState();
    final now = TimeOfDay.now();
    final rounded = now.minute - (now.minute % 5);

    _current = widget.viewModel.startTime != null
        ? DateTime(
            2000,
            1,
            1,
            widget.viewModel.startTime!.inHours,
            widget.viewModel.startTime!.inMinutes % 60,
          )
        : DateTime(2000, 1, 1, now.hour, rounded);
    widget.viewModel.setStartTime(
      Duration(hours: _current.hour, minutes: _current.minute),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: CupertinoDatePicker(
        backgroundColor: constants.background,
        mode: CupertinoDatePickerMode.time,
        use24hFormat: true,
        initialDateTime: _current,
        minuteInterval: 5,
        onDateTimeChanged: (dt) {
          _current = dt;
          widget.viewModel.setStartTime(
            Duration(hours: dt.hour, minutes: dt.minute),
          );
        },
      ),
    );
  }
}

class _DurationPicker extends StatefulWidget {
  final CreateBlockViewmodel viewModel;
  const _DurationPicker({required this.viewModel});

  @override
  State<_DurationPicker> createState() => _DurationPickerState();
}

class _DurationPickerState extends State<_DurationPicker> {
  late FixedExtentScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    _scrollController = FixedExtentScrollController(initialItem: 3);
    widget.viewModel.setDuration(Duration(minutes: 15));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: CupertinoPicker(
        backgroundColor: constants.background,
        itemExtent: 40,
        scrollController: _scrollController,
        onSelectedItemChanged: (index) {
          widget.viewModel.setDuration(Duration(minutes: index * 5));
        },
        children: List.generate(
          24,
          (i) => Center(
            child: Text(
              '${i * 5} min',
              style: TextStyle(fontSize: constants.fsBody),
            ),
          ),
        ),
      ),
    );
  }
}
