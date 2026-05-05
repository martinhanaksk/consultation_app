// edit_block_page.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Allows a teacher to manage an existing block: view and delete its slots,
// toggle the block's online mode, copy it to other dates, or delete it entirely.

import 'package:consultation_app/models/slot_model.dart';
import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/edit_block_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/custom_checkbox_widget.dart';
import 'package:consultation_app/views/custom_widgets/custom_date_range_picker_dialog.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class EditBlock extends StatefulWidget {
  final int roomId;
  final int blockId;
  // VoidCallback to refresh the parent page
  final VoidCallback? onSuccess;

  const EditBlock({
    super.key,
    required this.roomId,
    required this.blockId,
    required this.onSuccess,
  });

  @override
  State<EditBlock> createState() => _EditBlockState();
}

class _EditBlockState extends State<EditBlock> {
  late final EditBlockViewmodel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = EditBlockViewmodel();
    _viewModel.init(widget.blockId, widget.roomId);
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
      child: Consumer<EditBlockViewmodel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBarMenu(),
            drawer: SliderMenu(),
            backgroundColor: constants.background,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            'Edit block',
                            style: TextStyle(
                              fontSize: constants.fsHeadline,
                              fontWeight: constants.fwSemiBold,
                              color: constants.darkGrey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            "in",
                            style: TextStyle(
                              fontSize: constants.fsBody,
                              fontWeight: constants.fwRegular,
                              color: constants.darkGrey100,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            viewModel.roomName,
                            style: TextStyle(
                              fontSize: constants.fsBody,
                              fontWeight: constants.fwRegular,
                              color: constants.darkGrey100,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Column(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 24),
                                Center(
                                  child: Container(
                                    clipBehavior: Clip.hardEdge,
                                    width: MediaQuery.of(context).size.width * 0.9,
                                    decoration: constants.squircleShadow(
                                      hasBorder: true,
                                      color: constants.background,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Header row: block date centred, Add Slot button on the right
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.fromLTRB(
                                                20, 10, 20, 10,
                                              ),
                                              child: Text(
                                                viewModel.getBlockDate(),
                                                style: TextStyle(
                                                  color: constants.darkGrey,
                                                  fontSize: constants.fsLabel,
                                                  fontWeight: constants.fwSemiBold,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12.0,
                                              ),
                                              child: GestureDetector(
                                                onTap: () {
                                                  nav.toAddSlot(
                                                    blockId: widget.blockId,
                                                    // Refreshes slot list after a new slot is added
                                                    onSuccess: () => viewModel.refetchData(
                                                      widget.blockId,
                                                    ),
                                                  );
                                                },
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    svgs.icon(
                                                      'add',
                                                      constants.primary,
                                                      width: constants.fsTitle,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      "Add Slot",
                                                      style: TextStyle(
                                                        color: constants.primary,
                                                        fontWeight: constants.fwSemiBold,
                                                        fontSize: constants.fsLabel,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Divider(height: 1),
                                        // Three states: loading, empty, or slot list
                                        viewModel.isLoading
                                            ? Padding(
                                                padding: EdgeInsets.all(24),
                                                child: SpinKitPouringHourGlass(
                                                  color: constants.primary,
                                                  size: constants.fsTitle,
                                                ),
                                              )
                                            : viewModel.slots.isEmpty
                                            ? Padding(
                                                padding: const EdgeInsets.all(24),
                                                child: Text(
                                                  "No slots in this block.",
                                                  style: TextStyle(
                                                    color: constants.darkGrey,
                                                    fontSize: constants.fsLabel,
                                                  ),
                                                ),
                                              )
                                            : ListView.builder(
                                                shrinkWrap: true,
                                                physics: NeverScrollableScrollPhysics(),
                                                padding: EdgeInsets.zero,
                                                itemCount: viewModel.slots.length,
                                                itemBuilder: (context, index) {
                                                  final slot = viewModel.slots[index];
                                                  return _SlotRow(
                                                    slot: slot,
                                                    isFirst: index == 0,
                                                    isLast: index == viewModel.slots.length - 1,
                                                    onIsOnlineClicked: () =>
                                                        viewModel.changeSlotMeetingType(
                                                          slot.id,
                                                        ),
                                                    onDelete: () =>
                                                        viewModel.deleteSlot(slot.id),
                                                  );
                                                },
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 32),
                            // Toggles online mode for the entire block and notifies the parent
                            Row(
                              children: [
                                CustomCheckbox(
                                  value: viewModel.isChecked,
                                  onChanged: (bool? value) => {
                                    viewModel.toggleIsOnline(
                                      value,
                                      widget.blockId,
                                    ),
                                    widget.onSuccess!(),
                                  },
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
                            SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Copies the block's slot structure to one or more selected dates
                                ElevatedButton(
                                  onPressed: () {
                                    CustomDateRangePickerDialog.show(
                                      context: context,
                                      title: 'Copy to',
                                      selectionMode: viewModel.selectionMode,
                                      selectedDates: viewModel.selectedDates,
                                      onSelectionModeChanged: (mode) {
                                        viewModel.setSelectedDates(null);
                                        viewModel.setSelectionMode(mode);
                                      },
                                      onDatesSelected: (dates) =>
                                          viewModel.setSelectedDates(dates),
                                      onConfirm: () {
                                        Navigator.pop(context);
                                        viewModel.copyBlock(widget.roomId);
                                      },
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: constants.lightPrimary,
                                    fixedSize: const Size(140, 120),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(color: constants.background),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      svgs.icon(
                                        'copy',
                                        constants.primary,
                                        width: constants.fsHeadline,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        "Copy Block",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: constants.primary,
                                          fontWeight: constants.fwSemiBold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 24),
                                ElevatedButton(
                                  onPressed: () {
                                    viewModel.deleteBlock(widget.blockId);
                                    widget.onSuccess!();
                                    nav.pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: constants.red30,
                                    fixedSize: const Size(140, 120),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(color: constants.background),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      svgs.icon(
                                        'trash',
                                        constants.red,
                                        width: constants.fsHeadline,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        "Delete Block",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: constants.red,
                                          fontWeight: constants.fwSemiBold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
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

// Single row in the slot list showing start time, taken status, meeting type toggle, and delete
class _SlotRow extends StatelessWidget {
  final SlotModel slot;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onIsOnlineClicked;
  final VoidCallback onDelete;

  const _SlotRow({
    required this.slot,
    required this.isFirst,
    required this.isLast,
    required this.onIsOnlineClicked,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider is skipped for the first row to avoid a double border with the card header
        if (!isFirst) Divider(height: 1, color: constants.grey),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              // Displays time as "HH:mm"
              Text(
                '${slot.startTime.split(":")[0]}:${slot.startTime.split(":")[1]}',
                style: TextStyle(
                  color: constants.darkGrey,
                  fontSize: constants.fsLabel,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                slot.takenBy == null ? "" : "Taken",
                style: TextStyle(
                  color: constants.darkGrey,
                  fontSize: constants.fsLabel,
                  fontWeight: constants.fwSemiBold,
                ),
              ),
              const Spacer(),
              // Icon switches between location (in-person) and screen (online)
              GestureDetector(
                onTap: onIsOnlineClicked,
                child: svgs.icon(
                  slot.isOnline == 0 ? 'location' : 'screen',
                  constants.primary,
                  width: constants.fsTitle,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDelete,
                child: svgs.icon(
                  'trash',
                  constants.red,
                  width: constants.fsTitle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
