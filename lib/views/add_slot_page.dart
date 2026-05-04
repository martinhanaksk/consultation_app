import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/add_slot_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/custom_checkbox_widget.dart';
import 'package:consultation_app/views/custom_widgets/custom_text_field_widget.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/time_duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class AddSlot extends StatefulWidget {
  final int blockId;
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
                         TimeDurationPicker(
                          initialStartTime: viewModel.startTime,
                          initialDuration: viewModel.duration,
                          onStartTimeChanged: viewModel.setStartTime,
                          onDurationChanged: viewModel.setDuration,
                          durationLabel: 'Minutes per Slot',
                          startTimeLabel: 'Slot Start Time',
                        ),
                        const SizedBox(height: 20),
                        Container(
                          clipBehavior: Clip.none,
                          decoration: constants.squircleShadow(
                            color: constants.background,
                            hasBorder: true,
                          ),
                          child: CustomInputTextField(
                            controller: viewModel.noteController,
                            hintText: 'Note',
                            maxLength: 50,
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
                                    FocusScope.of(context).unfocus();
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
