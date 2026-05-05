import 'dart:convert';

import 'package:consultation_app/setup.dart';
import 'package:consultation_app/utils/time_utils.dart';
import 'package:consultation_app/utils/time_validation_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

enum TimePickerAction { startTime, endTime, duration }

class CreateBlockViewmodel extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────

  bool isLoading = false;
  String dateCount = '';
  String range = '';

  bool _isChecked = false;
  Duration? _startTime;
  Duration? _endTime;
  Duration? _duration;
  DateRangePickerSelectionMode _selectionMode =
      DateRangePickerSelectionMode.multiple;
  dynamic _selectedDates;

  final TextEditingController slotNumberController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  static final DateFormat _fmt = DateFormat('MMM d');
  static final DateFormat _fmtYear = DateFormat('MMM d, y');

  // ── Constructor / Lifecycle ────────────────────────────────────────────────

  CreateBlockViewmodel() {
    slotNumberController.addListener(updateEndTime);
  }

  @override
  void dispose() {
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

  // ── Public Methods ─────────────────────────────────────────────────────────

  String getPrintableTimeFormat(TimePickerAction action) {
    final time = switch (action) {
      TimePickerAction.startTime => startTime ?? Duration.zero,
      TimePickerAction.endTime => endTime ?? Duration.zero,
      TimePickerAction.duration => duration ?? Duration.zero,
    };
    return TimeUtils.formatTime(time);
  }

  void updateEndTime() {
    if (_startTime == null || _duration == null) return;
    final slots = int.tryParse(slotNumberController.text.trim());
    if (slots == null || slots <= 0) return;

    final computed = TimeUtils.computeEndTime(_startTime!, _duration!, slots);
    _endTime = computed;
    if (computed != null) notifyListeners();
  }

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

  List<String> getSelectedDatesIso() {
    if (_selectedDates == null) return [];

    switch (_selectionMode) {
      case DateRangePickerSelectionMode.multiple:
        return (_selectedDates as List<DateTime>).map(_formatDateIso).toList();

      case DateRangePickerSelectionMode.range:
        final r = _selectedDates as PickerDateRange;
        if (r.startDate == null) return [];
        return _expandDateRange(r.startDate!, r.endDate ?? r.startDate!);

      default:
        return [];
    }
  }

  Future<void> createBlock(int roomId, VoidCallback? onSuccess) async {
    final slotCount = int.tryParse(slotNumberController.text.trim());
    final dates = getSelectedDatesIso();

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

    try {
      final note = noteController.text.trim();
      final isOnline = _isChecked ? 1 : 0;

      for (final date in dates) {
        final response = await api.createBlock(roomId, date);
        if (response.isEmpty) {
          notify.showToast(
            'Failed to create block for $date. It might already exist',
            isError: true,
          );
          continue;
        }

        notify.showToast('Blocks created successfully');
        final blockId = jsonDecode(response)['id'] as int;
        final created = await _createSlotsForBlock(blockId, slotCount!, isOnline, note);
        if (!created) return;
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

  String _formatDate(DateTime d) {
    return d.year == DateTime.now().year ? _fmt.format(d) : _fmtYear.format(d);
  }

  String _formatDateIso(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  List<String> _expandDateRange(DateTime start, DateTime end) {
    final dates = <String>[];
    DateTime current = start;
    while (!current.isAfter(end)) {
      dates.add(_formatDateIso(current));
      current = current.add(const Duration(days: 1));
    }
    return dates;
  }

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
        notify.showToast('Failed to create slot $j for block $blockId', isError: true);
        return false;
      }
    }
    return true;
  }
}
