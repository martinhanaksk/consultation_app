import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class CreateBlockViewmodel extends ChangeNotifier {
  // --- Date Picker ---
  String dateCount = '';
  String range = '';
  DateRangePickerSelectionMode _selectionMode =
      DateRangePickerSelectionMode.multiple;
  DateRangePickerSelectionMode get selectionMode => _selectionMode;
  dynamic _selectedDates;
  dynamic get selectedDates => _selectedDates;
  static final DateFormat _fmt = DateFormat('MMM d');
  static final DateFormat _fmtYear = DateFormat('MMM d, y');
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
    notifyListeners();
  }

  void setEndTime(Duration value) {
    _endTime = value;
    notifyListeners();
  }

  void setDuration(Duration value) {
    _duration = value;
    notifyListeners();
  }

  // --- Note ---
  final TextEditingController noteController = TextEditingController();

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }
}

enum TimePickerAction { startTime, endTime, duration }
