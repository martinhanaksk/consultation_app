import 'package:consultation_app/models/slot_model.dart';
import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/edit_block_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class EditBlock extends StatefulWidget {
  final String token;
  final String roomId;
  final String blockId;
  final VoidCallback? onSuccess;
  const EditBlock({
    super.key,
    required this.token,
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
    _viewModel.init(widget.token, widget.blockId, widget.roomId);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _showDatePickerDialog(
    BuildContext context,
    EditBlockViewmodel viewModel,
    String blockId,
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
                    'Copy to',
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
                    viewModel.copyBlock(widget.token,widget.roomId);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: constants.squircleShadow(
                      color: constants.primary,
                    ),
                    child: Text(
                      'Copy',
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
      child: Consumer<EditBlockViewmodel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBarMenu(),
            drawer: SliderMenu(),
            backgroundColor: constants.background,
            body: SafeArea(
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
                      const SizedBox(height: 32),
                      Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              Center(
                                child: Container(
                                  clipBehavior: Clip.hardEdge,
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  decoration: constants.squircleShadow(
                                    border: Border.all(
                                      color: constants.grey,
                                      width: 0.2,
                                    ),
                                    color: constants.background,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              20,
                                              10,
                                              20,
                                              10,
                                            ),
                                            child: Text(
                                              viewModel.getBlockDate(),
                                              style: TextStyle(
                                                color: constants.darkGrey,
                                                fontSize: constants.fsLabel,
                                                fontWeight:
                                                    constants.fwSemiBold,
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
                                                  token: widget.token,
                                                  blockId: widget.blockId,
                                                  onSuccess: () =>
                                                      viewModel.refetchData(
                                                        widget.token,
                                                        widget.blockId,
                                                      ),
                                                );
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/resources/take_slot.svg',
                                                    color: constants.primary,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    "Add Slot",
                                                    style: TextStyle(
                                                      color: constants.primary,
                                                      fontWeight:
                                                          constants.fwSemiBold,
                                                      fontSize:
                                                          constants.fsLabel,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Block header row
                                      const Divider(height: 1),
                                      // Slot list
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
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              padding: EdgeInsets.zero,
                                              itemCount: viewModel.slots.length,
                                              itemBuilder: (context, index) {
                                                final slot =
                                                    viewModel.slots[index];
                                                return _SlotRow(
                                                  slot: slot,
                                                  isFirst: index == 0,
                                                  isLast:
                                                      index ==
                                                      viewModel.slots.length -
                                                          1,
                                                  onHistoryClicked: () => {
                                                    viewModel
                                                        .displayHistoryOfSlot(
                                                          widget.token,
                                                          slot.id,
                                                          int.parse(
                                                            widget.blockId,
                                                          ),
                                                        ),
                                                  },
                                                  onIsOnlineClicked: () async => {
                                                    await viewModel
                                                        .changeSlotMeetingType(
                                                          widget.token,
                                                          slot.id,
                                                        ),
                                                    await viewModel
                                                        .fetchSlotsForBlock(
                                                          widget.token,
                                                          widget.blockId,
                                                        ),
                                                  },
                                                  onDelete: () => {
                                                    viewModel.deleteSlot(
                                                      widget.token,
                                                      slot.id,
                                                    ),
                                                    viewModel
                                                        .fetchSlotsForBlock(
                                                          widget.token,
                                                          widget.blockId,
                                                        ),
                                                  },
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  _showDatePickerDialog(
                                    context,
                                    viewModel,
                                    widget.blockId,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: constants.primary.withAlpha(
                                    30,
                                  ),
                                  fixedSize: const Size(140, 120),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: constants.background,
                                    ),
                                  ),
                                  elevation: 0,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.copy,
                                      color: constants.primary,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "Copy Block",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: constants.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              ElevatedButton(
                                onPressed: () {
                                  viewModel.deleteBlock(
                                    widget.token,
                                    widget.blockId,
                                  );
                                  widget.onSuccess!();
                                  nav.pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: constants.red.withAlpha(30),
                                  fixedSize: const Size(140, 120),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: constants.background,
                                    ),
                                  ),
                                  elevation: 0,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.delete_outline_rounded,
                                      color: constants.red,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "Delete Block",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: constants.red,
                                        fontWeight: FontWeight.w600,
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
          );
        },
      ),
    );
  }
}

class _SlotRow extends StatelessWidget {
  final SlotModel slot;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onIsOnlineClicked;
  final VoidCallback onHistoryClicked;
  final VoidCallback onDelete;

  const _SlotRow({
    required this.slot,
    required this.isFirst,
    required this.isLast,
    required this.onIsOnlineClicked,
    required this.onHistoryClicked,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!isFirst) Divider(height: 1, color: constants.grey),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Text(
                '${slot.startTime.split(":")[0]}${":"}${slot.startTime.split(":")[1]}',
                style: TextStyle(
                  color: constants.darkGrey,
                  fontSize: constants.fsLabel,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: onHistoryClicked,
                    child: Icon(
                      Icons.history_outlined,
                      color: constants.darkGrey,
                      size: 32,
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: onIsOnlineClicked,
                    child: slot.isOnline == 0
                        ? Icon(
                            Icons.monitor,
                            color: constants.primary,
                            size: 32,
                          )
                        : Icon(
                            Icons.location_pin,
                            color: constants.primary,
                            size: 32,
                          ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: onDelete,
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: constants.red,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
