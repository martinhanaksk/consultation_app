import 'dart:convert';

import 'package:consultation_app/setup.dart';
import 'package:consultation_app/utils/time_utils.dart';
import 'package:consultation_app/utils/time_validation_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class CreateBlockViewmodel extends ChangeNotifier {
  bool isLoading = false;
  bool _isChecked = false;
  bool get isChecked => _isChecked;
  String dateCount = '';
  String range = '';
  DateRangePickerSelectionMode _selectionMode =
      DateRangePickerSelectionMode.multiple;
  DateRangePickerSelectionMode get selectionMode => _selectionMode;
  dynamic _selectedDates;
  dynamic get selectedDates => _selectedDates;
  static final DateFormat _fmt = DateFormat('MMM d');
  static final DateFormat _fmtYear = DateFormat('MMM d, y');
  final TextEditingController slotNumberController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  void toggleIsOnline(bool? value) {
    _isChecked = value ?? false;
    notifyListeners();
  }

  CreateBlockViewmodel() {
    slotNumberController.addListener(updateEndTime);
  }
  String _formatDate(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year ? _fmt.format(d) : _fmtYear.format(d);
  }

  String getSelectedDatesFormatted() {
    if (selectedDates != null) {
      switch (selectionMode) {
        case DateRangePickerSelectionMode.range:
          final PickerDateRange r = _selectedDates as PickerDateRange;
          final start = r.startDate != null ? _formatDate(r.startDate!) : '?';
          final end = r.endDate != null ? _formatDate(r.endDate!) : '?';
          return '$start – $end';
        case DateRangePickerSelectionMode.multiple:
          final List<DateTime> dates = _selectedDates as List<DateTime>;
          if (dates.isEmpty) return ' ';
          final previews = dates.take(3).map(_formatDate).join(', ');
          return dates.length > 3 ? "$previews..." : previews;
        default:
          return "None";
      }
    } else {
      return "None";
    }
  }

  void setSelectedDates(dynamic value) {
    _selectedDates = value;
    notifyListeners();
  }

  void setSelectionMode(DateRangePickerSelectionMode mode) {
    _selectionMode = mode;
    notifyListeners();
  }

  void setDateCount(String value) {
    dateCount = value;
    notifyListeners();
  }

  void setRange(String value) {
    range = value;
    notifyListeners();
  }

  String _formatDateIso(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  List<String> getSelectedDatesIso() {
    if (_selectedDates == null) return [];

    switch (_selectionMode) {
      case DateRangePickerSelectionMode.multiple:
        final List<DateTime> dates = _selectedDates as List<DateTime>;
        return dates.map(_formatDateIso).toList();

      case DateRangePickerSelectionMode.range:
        final PickerDateRange r = _selectedDates as PickerDateRange;
        if (r.startDate == null) return [];
        final end = r.endDate ?? r.startDate!;
        return _expandDateRange(r.startDate!, end);

      default:
        return [];
    }
  }

  List<String> _expandDateRange(DateTime start, DateTime end) {
    final List<String> dates = [];
    DateTime current = start;
    while (!current.isAfter(end)) {
      dates.add(_formatDateIso(current));
      current = current.add(const Duration(days: 1));
    }
    return dates;
  }

  Duration? _startTime;
  Duration? _endTime;
  Duration? _duration;
  Duration? get startTime => _startTime;
  Duration? get endTime => _endTime;
  Duration? get duration => _duration;
  void setStartTime(Duration value) {
    _startTime = value;
    updateEndTime();
  }

  void setEndTime(Duration value) {
    _endTime = value;

    notifyListeners();
  }

  void setDuration(Duration value) {
    _duration = value;
    updateEndTime();
  }

  String getPrintableTimeFormat(TimePickerAction action) {
    String result = "";
    final temp = switch (action) {
      TimePickerAction.startTime => startTime ?? Duration(hours: 0),
      TimePickerAction.endTime => endTime ?? Duration(hours: 0),
      TimePickerAction.duration => duration ?? Duration(hours: 0),
    };
    result = TimeUtils.formatTime(temp);
    return result;
  }

  void updateEndTime() {
    if (_startTime == null ||
        _duration == null ||
        slotNumberController.text.trim().isEmpty) {
      return;
    }

    final slots = int.tryParse(slotNumberController.text.trim());
    if (slots == null || slots <= 0) return;
    final resultEndTime = TimeUtils.computeEndTime(
      _startTime!,
      _duration!,
      slots,
    );
    if (resultEndTime == null) {
      _endTime = null;
      return;
    }
    setEndTime(resultEndTime);
  }

  @override
  void dispose() {
    noteController.dispose();
    slotNumberController.dispose();
    super.dispose();
  }

  void createBlock(int roomId, VoidCallback? onSuccess) async {
    isLoading = true;
    notifyListeners();
    final slotCount = int.tryParse(slotNumberController.text.trim());
    final error = TimeValidationUtils.validateBlockCreation(
      selectedDates: getSelectedDatesIso(),
      startTime: startTime,
      duration: duration,
      slotCount: slotCount,
      endTime: _endTime,
    );
    if (error != null) {
      notify.showToast(error,isError: true);
      isLoading = false;
      notifyListeners();
      return;
    }

    List<String> dates = getSelectedDatesIso();
    final String note = noteController.text.trim();
    final int isOnline = isChecked ? 1 : 0;
    for (int i = 0; i < dates.length; i++) {
      String response = await api.createBlock(roomId, dates[i]);

      if (response.isEmpty) {
        notify.showToast(
          'Failed to create block for ${dates[i]}. It might already exist',isError: true,
        );
        continue;
      } else {
        notify.showToast('Blocks created successfully');
      }
      final int blockId = jsonDecode(response)['id'];
      if (slotCount != 0) {
        for (int j = 0; j < slotCount!; j++) {
          final Duration slotStart = _startTime! + (_duration! * j);
          final String startTimeStr = TimeUtils.formatTimeWithSeconds(
            slotStart,
          );
          bool success = await api.createSlot(
            blockId,
            startTimeStr,
            _duration!.inMinutes,
            isOnline,
            note,
          );
          if (!success) {
            notify.showToast('Failed to create slot $j for block $blockId',isError: true);
            isLoading = false;
            notifyListeners();
            return;
          }
        }
      }
    }

    isLoading = false;
    notifyListeners();
    onSuccess?.call();

    nav.pop();
  }
}

enum TimePickerAction { startTime, endTime, duration }
