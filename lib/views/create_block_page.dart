// create_block_page.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Form for creating a new consultation block within a room.
// A block defines one or more dates, a start time, slot duration,
// slot count, (endTime is calculated automatically) and an optional note, and whether slots are online or in-person.

import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/create_block_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/custom_checkbox_widget.dart';
import 'package:consultation_app/views/custom_widgets/custom_date_range_picker_dialog.dart';
import 'package:consultation_app/views/custom_widgets/custom_text_field_widget.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/time_duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class CreateBlock extends StatefulWidget {
  final int roomId;
  // Called after successful block creation to refresh the parent room view
  final VoidCallback? onSuccess;

  const CreateBlock({super.key, required this.roomId, required this.onSuccess});

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
                        // Tapping opens the date picker dialog
                        GestureDetector(
                          onTap: () => CustomDateRangePickerDialog.show(
                            context: context,
                            title: 'Select Dates',
                            selectionMode: viewModel.selectionMode,
                            selectedDates: viewModel.selectedDates,
                            onSelectionModeChanged: (mode) {
                              viewModel.setSelectedDates(null);
                              viewModel.setSelectionMode(mode);
                            },
                            onDatesSelected: (dates) =>
                                viewModel.setSelectedDates(dates),
                            onConfirm: () => Navigator.pop(context),
                          ),
                          child: Container(
                            height: 56,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: constants.squircleShadow(
                              color: constants.background,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Selected: ${viewModel.getSelectedDatesFormatted()}',
                                    style: TextStyle(  overflow: TextOverflow.ellipsis,
                                      fontSize: constants.fsLabel,
                                      color: constants.darkGrey,
                                    ),
                                  ),
                                ),
                                svgs.icon(
                                  'calendar',
                                  constants.darkGrey,
                                  width: constants.fsTitle,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        TimeDurationPicker(
                          initialStartTime: viewModel.startTime,
                          initialDuration: viewModel.duration,
                          onStartTimeChanged: viewModel.setStartTime,
                          onDurationChanged: viewModel.setDuration,
                          durationLabel: 'Minutes per Slot',
                          startTimeLabel: 'Block Start Time',
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
                                child: CustomInputTextField(
                                  controller: viewModel.slotNumberController,
                                  hintText: 'Slots',
                                  keyboardType: TextInputType.number,
                                  maxLength: 3,
                                ),
                              ),
                            ),
                            Flexible(flex: 1, child: SizedBox()),
                            // End time is computed from start + (slots × duration)
                            // and it is read-only
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
                                          color: constants.darkGrey,
                                        ),
                                      ),
                                      svgs.icon(
                                        'clock',
                                        constants.darkGrey,
                                        width: constants.fsTitle,
                                      ),
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
                          child: CustomInputTextField(
                            controller: viewModel.noteController,
                            hintText: 'Note',
                            maxLength: 50,
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            CustomCheckbox(
                              value: viewModel.isChecked,
                              onChanged: viewModel.toggleIsOnline,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Online',
                              style: TextStyle(
                                color: constants.darkGrey,
                                fontSize: constants.fsBody,
                              ),
                            ),
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
                                    FocusScope.of(context).unfocus(),
                                    viewModel.createBlock(
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
