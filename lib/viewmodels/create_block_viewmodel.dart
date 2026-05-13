// create_block_viewmodel.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// ViewModel for the Create Block screen. Manages date selection (single dates
// or a range), start time, slot duration, and slot count. On submit it creates
// one block per selected date and fills each block with consecutive slots.

import 'dart:convert';
import 'package:consultation_app/setup.dart';
import 'package:consultation_app/utils/time_utils.dart';
import 'package:consultation_app/utils/time_validation_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

enum TimePickerAction { startTime, endTime, duration }

class CreateBlockPageViewModel extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────
  bool isLoading = false;
  String dateCount = '';
  String range = '';
  bool _isChecked = false;
  Duration? _startTime;
  Duration? _endTime;
  Duration? _duration;
  // Prevents notifyListeners() from firing after the widget tree is disposed
  bool _disposed = false;
  DateRangePickerSelectionMode _selectionMode =
      DateRangePickerSelectionMode.multiple;
  dynamic _selectedDates;

  final TextEditingController slotNumberController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  // No year when the date falls in the current year
  static final DateFormat _fmt = DateFormat('MMM d');
  static final DateFormat _fmtYear = DateFormat('MMM d, y');

  // ── Constructor / Lifecycle ────────────────────────────────────────────────

  CreateBlockPageViewModel() {
    // Recalculate end time whenever the slot count changes
    slotNumberController.addListener(updateEndTime);
  }

  @override
  void dispose() {
    _disposed = true;
    noteController.dispose();
    slotNumberController.dispose();
    super.dispose();
  }

  // ── Getters ────────────────────────────────────────────────────────────────

  bool get isChecked => _isChecked;
  Duration? get startTime => _startTime;
  Duration? get endTime => _endTime;
  Duration? get duration => _duration;
  DateRangePickerSelectionMode get selectionMode => _selectionMode;
  dynamic get selectedDates => _selectedDates;

  // ── Setters ────────────────────────────────────────────────────────────────

  void toggleIsOnline(bool? value) {
    _isChecked = value ?? false;
    notifyListeners();
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

  void setStartTime(Duration value) {
    _startTime = value;
    // Changing start time affects end time, so recalculate immediately
    updateEndTime();
  }

  void setEndTime(Duration value) {
    _endTime = value;
    notifyListeners();
  }

  void setDuration(Duration value) {
    _duration = value;
    // Changing duration affects end time, so recalculate immediately
    updateEndTime();
  }

  // ── Public Methods ─────────────────────────────────────────────────────────

  String getPrintableTimeFormat(TimePickerAction action) {
    final time = switch (action) {
      TimePickerAction.startTime => startTime ?? Duration.zero,
      TimePickerAction.endTime => endTime ?? Duration.zero,
      TimePickerAction.duration => duration ?? Duration.zero,
    };
    return TimeUtils.formatTime(time);
  }

  // Derives end time from start + (duration × slot count); no-ops if any
  // required input is missing
  void updateEndTime() {
    if (_startTime == null || _duration == null) return;
    final slots = int.tryParse(slotNumberController.text.trim());
    if (slots == null || slots <= 0) return;

    final computed = TimeUtils.computeEndTime(_startTime!, _duration!, slots);
    _endTime = computed;
    if (computed != null) notifyListeners();
  }

  // Returns a human-readable summary of the current date selection.
  // Range mode: "Jan 5 – Jan 10"; multiple mode: up to 3 dates then "..."
  String getSelectedDatesFormatted() {
    if (_selectedDates == null) return 'None';

    switch (_selectionMode) {
      case DateRangePickerSelectionMode.range:
        final r = _selectedDates as PickerDateRange;
        final start = r.startDate != null ? _formatDate(r.startDate!) : '?';
        final end = r.endDate != null ? _formatDate(r.endDate!) : '?';
        return '$start – $end';

      case DateRangePickerSelectionMode.multiple:
        final dates = _selectedDates as List<DateTime>;
        if (dates.isEmpty) return ' ';
        final previews = dates.take(3).map(_formatDate).join(', ');
        return dates.length > 3 ? '$previews...' : previews;

      default:
        return 'None';
    }
  }

  // Expands the current selection into a list of date strings,
  // ready to pass to the API
  List<String> getSelectedDatesForApi() {
    if (_selectedDates == null) return [];

    switch (_selectionMode) {
      case DateRangePickerSelectionMode.multiple:
        return (_selectedDates as List<DateTime>).map(_formatDateIso).toList();

      case DateRangePickerSelectionMode.range:
        final r = _selectedDates as PickerDateRange;
        if (r.startDate == null) return [];
        // When only a start date is picked, treat it as a single-day range
        return _expandDateRange(r.startDate!, r.endDate ?? r.startDate!);

      default:
        return [];
    }
  }

  Future<void> createBlock(int roomId, VoidCallback? onSuccess) async {
    final slotCount = int.tryParse(slotNumberController.text.trim());
    final dates = getSelectedDatesForApi();

    final error = TimeValidationUtils.validateBlockCreation(
      selectedDates: dates,
      startTime: _startTime,
      duration: _duration,
      slotCount: slotCount,
      endTime: _endTime,
    );
    if (error != null) {
      notify.showToast(error, isError: true);
      return;
    }
    _setLoading(true);
    final createdBlockIds = <int>[];
    var anySucceeded = false;
    try {
      final note = noteController.text.trim();
      // API expects an integer flag: 1 = online, 0 = in-person
      final isOnline = _isChecked ? 1 : 0;
      for (final date in dates) {
        final response = await api.createBlock(roomId, date);
        // An empty response means the block already exists for this date
        if (response.isEmpty) {
          notify.showToast(
            'Failed to create block for $date. It might already exist',
            isError: true,
          );
          // Skip this date but continue trying the remaining ones
          continue;
        }

        final blockId = jsonDecode(response)['id'] as int;
        createdBlockIds.add(blockId);
        final created = await _createSlotsForBlock(
          blockId,
          slotCount!,
          isOnline,
          note,
        );
        if (!created) {
          for (final id in createdBlockIds) {
            await api.deleteBlock(id);
          }
          return;
        }
        anySucceeded = true;
      }
      if (anySucceeded) {
        notify.showToast('Blocks created successfully');
      }
    } finally {
      _setLoading(false);
    }
    onSuccess?.call();
    nav.pop();
  }

  // ── Private Helpers ────────────────────────────────────────────────────────
  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  // No year when the date is in the current calendar year
  String _formatDate(DateTime d) {
    return d.year == DateTime.now().year ? _fmt.format(d) : _fmtYear.format(d);
  }

  String _formatDateIso(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  // Iterates day by day from start to end to produce string list
  List<String> _expandDateRange(DateTime start, DateTime end) {
    final dates = <String>[];
    DateTime current = start;
    while (!current.isAfter(end)) {
      dates.add(_formatDateIso(current));
      current = current.add(const Duration(days: 1));
    }
    return dates;
  }

  // Creates slots starting at _startTime, each spaced
  // by _duration. Returns false and shows a toast on the first failure.
  Future<bool> _createSlotsForBlock(
    int blockId,
    int slotCount,
    int isOnline,
    String note,
  ) async {
    for (int j = 0; j < slotCount; j++) {
      final slotStart = _startTime! + (_duration! * j);
      final startTimeStr = TimeUtils.formatTimeWithSeconds(slotStart);
      final success = await api.createSlot(
        blockId,
        startTimeStr,
        _duration!.inMinutes,
        isOnline,
        note,
      );
      if (!success) {
        notify.showToast(
          'Failed to create slot $j for block $blockId',
          isError: true,
        );
        return false;
      }
    }
    return true;
  }

  // Overridden to guard against async callbacks firing after dispose()
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }
}
