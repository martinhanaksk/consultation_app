import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:consultation_app/setup.dart';

class CustomDateRangePickerDialog {

  static Future<void> show ({
    required BuildContext context,
    required String title,
    required DateRangePickerSelectionMode selectionMode,
    required dynamic selectedDates,
    required void Function(DateRangePickerSelectionMode) onSelectionModeChanged,
    required void Function(dynamic) onDatesSelected,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool showActions = true,
  }) async {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return _DateRangePickerDialogContent(
          title: title,
          selectionMode: selectionMode,
          selectedDates: selectedDates,
          onSelectionModeChanged: onSelectionModeChanged,
          onDatesSelected: onDatesSelected,
          onConfirm: onConfirm ?? () => Navigator.pop(dialogContext),
          onCancel: onCancel ?? () {
            onDatesSelected(null);
            Navigator.pop(dialogContext);
          },
        );
      },
    );
  }
}

class _DateRangePickerDialogContent extends StatefulWidget {
  final String title;
  final DateRangePickerSelectionMode selectionMode;
  final dynamic selectedDates;
  final void Function(DateRangePickerSelectionMode) onSelectionModeChanged;
  final void Function(dynamic) onDatesSelected;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _DateRangePickerDialogContent({
    required this.title,
    required this.selectionMode,
    required this.selectedDates,
    required this.onSelectionModeChanged,
    required this.onDatesSelected,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<_DateRangePickerDialogContent> createState() =>
      _DateRangePickerDialogContentState();
}

class _DateRangePickerDialogContentState
    extends State<_DateRangePickerDialogContent> {
  late DateRangePickerSelectionMode _currentMode;
  late dynamic _currentSelection;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.selectionMode;
    _currentSelection = widget.selectedDates;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: constants.background,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              color: constants.darkGrey,
              fontWeight: constants.fwSemiBold,
              fontSize: constants.fsTitle,
            ),
          ),
          Container(
            color: constants.background,
            child: PopupMenuButton<DateRangePickerSelectionMode>(
              position: PopupMenuPosition.under,
              offset: const Offset(0, 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: constants.background,
              elevation: 12,
              shadowColor: constants.darkGrey30,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: constants.squircleShadow(
                  color: constants.background,
                ),
                child: Text(
                  _currentMode.name[0].toUpperCase() +
                      _currentMode.name.substring(1).toLowerCase(),
                  style: TextStyle(
                    color: constants.darkGrey,
                    fontWeight: constants.fwSemiBold,
                    fontSize: constants.fsLabel,
                  ),
                ),
              ),
              itemBuilder: (context) => [
                PopupMenuItem<DateRangePickerSelectionMode>(
                  value: DateRangePickerSelectionMode.multiple,
                  child: const Text('Multiple'),
                ),
                PopupMenuItem<DateRangePickerSelectionMode>(
                  value: DateRangePickerSelectionMode.range,
                  child: const Text('Range'),
                ),
              ],
              onSelected: (mode) {
                if (mode != null) {
                  setState(() {
                    _currentMode = mode;
                    _currentSelection = null;
                  });
                  widget.onSelectionModeChanged(mode);
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
          monthCellStyle: DateRangePickerMonthCellStyle(
            textStyle: TextStyle(
              color: constants.darkGrey,
              fontSize: constants.fsLabel,
            ),
            todayTextStyle: TextStyle(
              color: constants.primary,
              fontWeight: constants.fwSemiBold,
            ),
            trailingDatesTextStyle: TextStyle(
              color: constants.darkGrey.withValues(alpha: 0.3),
            ),
            leadingDatesTextStyle: TextStyle(
              color: constants.darkGrey30,
            ),
          ),
          yearCellStyle: DateRangePickerYearCellStyle(
            textStyle: TextStyle(
              color: constants.darkGrey,
              fontSize: constants.fsLabel,
            ),
            todayTextStyle: TextStyle(
              color: constants.primary,
              fontWeight: constants.fwSemiBold,
            ),
            leadingDatesTextStyle: TextStyle(
              color: constants.darkGrey30,
            ),
            disabledDatesTextStyle: TextStyle(
              color: constants.darkGrey30,
            ),
          ),
          selectionTextStyle: TextStyle(
            color: constants.background,
            fontWeight: constants.fwRegular,
            fontSize: constants.fsLabel,
          ),
          rangeTextStyle: TextStyle(
            color: constants.background,
            fontWeight: constants.fwRegular,
            fontSize: constants.fsLabel,
          ),
          backgroundColor: constants.background,
          selectionColor: constants.primary,
          rangeSelectionColor: constants.lightPrimary,
          todayHighlightColor: constants.lightPrimary,
          startRangeSelectionColor: constants.primary,
          endRangeSelectionColor: constants.primary,
          view: DateRangePickerView.month,
          selectionMode: _currentMode,
          initialSelectedDates:
              _currentMode == DateRangePickerSelectionMode.multiple
                  ? _currentSelection
                  : null,
          initialSelectedRange:
              _currentMode == DateRangePickerSelectionMode.range
                  ? _currentSelection
                  : null,
          onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
            setState(() {
              _currentSelection = args.value;
            });
            widget.onDatesSelected(args.value);
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onDatesSelected(null);
            widget.onCancel();
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
        ElevatedButton(
          onPressed: widget.onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: constants.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 2,
            shadowColor: constants.primary,
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
      ],
    );
  }
}
