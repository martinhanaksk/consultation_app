import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/add_slot_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/custom_checkbox_widget.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class AddSlot extends StatefulWidget {
  final String blockId;
  final VoidCallback? onSuccess;

  const AddSlot({super.key, required this.blockId, required this.onSuccess});

  @override
  State<AddSlot> createState() => _AddSlotState();
}

class _AddSlotState extends State<AddSlot> {
  late final AddSlotViewmodel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AddSlotViewmodel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<AddSlotViewmodel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBarMenu(),
            drawer: SliderMenu(),
            backgroundColor: constants.background,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Text(
                          'Create Slot',
                          style: TextStyle(
                            color: constants.darkGrey,
                            fontWeight: constants.fwSemiBold,
                            fontSize: constants.fsHeadline,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 8,
                              child: Column(
                                children: [
                                  Text(
                                    'Minutes per Slot',
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
                            const Flexible(flex: 1, child: SizedBox()),
                            Flexible(
                              flex: 10,
                              child: Column(
                                children: [
                                  Text(
                                    'Slot Start Time',
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
                        const SizedBox(height: 20),
                        Container(
                          clipBehavior: Clip.none,
                          decoration: constants.squircleShadow(
                            color: constants.background,
                            hasBorder: true,
                          ),
                          child: TextField(
                            style: TextStyle(color: constants.darkGrey),
                            scrollPadding: const EdgeInsets.only(bottom: 1000),
                            controller: viewModel.noteController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              hintText: 'Note',
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                             CustomCheckbox(
                              value: viewModel.isOnline,
                              onChanged: viewModel.toggleIsOnline,
                            ),

                            const SizedBox(width: 8),
                            Text(
                              'Online',
                              style: TextStyle(
                                color: constants.darkGrey,
                                fontSize: constants.fsBody,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
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
                                  onPressed: () {
                                    if (viewModel.duration == null ||
                                        viewModel.duration!.inMinutes == 0) {
                                      notify.showToast(
                                        'Duration must be greater than 0 minutes',
                                      );
                                      return;
                                    }
                                    if (viewModel.startTime == null) {
                                      notify.showToast(
                                        'Please select a start time',
                                      );
                                      return;
                                    }
                                    viewModel.addSlot(
                                      widget.blockId,
                                      widget.onSuccess,
                                    );
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
  final AddSlotViewmodel viewModel;
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.setStartTime(
        Duration(hours: _current.hour, minutes: _current.minute),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
          initialDateTime: _current,
          minuteInterval: 5,
          onDateTimeChanged: (dt) {
            _current = dt;
            widget.viewModel.setStartTime(
              Duration(hours: dt.hour, minutes: dt.minute),
            );
          },
        ),
      ),
    );
  }
}

class _DurationPicker extends StatefulWidget {
  final AddSlotViewmodel viewModel;
  const _DurationPicker({required this.viewModel});

  @override
  State<_DurationPicker> createState() => _DurationPickerState();
}

class _DurationPickerState extends State<_DurationPicker> {
  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = FixedExtentScrollController(initialItem: 2);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.setDuration(const Duration(minutes: 15));
    });
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
          widget.viewModel.setDuration(Duration(minutes: (index + 1) * 5));
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
    );
  }
}
