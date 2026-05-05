// add_slot_viewmodel.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// ViewModel for the Add Slot screen. Holds form state (start time, duration,
// online flag, note), validates inputs, and calls the API to create a slot.

import 'package:consultation_app/setup.dart';
import 'package:consultation_app/utils/time_utils.dart';
import 'package:flutter/material.dart';

class AddSlotViewmodel extends ChangeNotifier {
  bool isLoading = false;
  bool _isOnline = false;
  bool get isOnline => _isOnline;
  final TextEditingController noteController = TextEditingController();
  Duration? _startTime;
  Duration? _duration;
  Duration? get startTime => _startTime;
  Duration? get duration => _duration;
  void toggleIsOnline(bool? value) {
    // Nullable bool comes from Checkbox; default to false if null
    _isOnline = value ?? false;
    notifyListeners();
  }

  void setStartTime(Duration value) {
    _startTime = value;
    notifyListeners();
  }

  void setDuration(Duration value) {
    _duration = value;
    notifyListeners();
  }

  // Returns a localised error message if required fields are missing, null if valid
  String? validateCreate() {
    if (_startTime == null) return 'Please set a start time';
    if (_duration == null || _duration!.inMinutes == 0) {
      return 'Please set a duration';
    }
    return null;
  }

  void addSlot(int blockId, VoidCallback? onSuccess) async {
    isLoading = true;
    notifyListeners();

    final error = validateCreate();
    if (error != null) {
      notify.showToast(error, isError: true);
      isLoading = false;
      notifyListeners();
      return;
    }

    final String startTimeStr = TimeUtils.formatTimeWithSeconds(_startTime!);
    final int durationMinutes = _duration!.inMinutes;
    // API expects an integer flag: 1 = online, 0 = in-person
    final int isOnlineInt = _isOnline ? 1 : 0;
    final String note = noteController.text.trim();
    final bool success = await api.createSlot(
      blockId,
      startTimeStr,
      durationMinutes,
      isOnlineInt,
      note,
    );

    // A false response means a slot already exists at the chosen time
    if (!success) {
      notify.showToast('Slot for selected time already exists');
      isLoading = false;
      notifyListeners();
      return;
    }
    notify.showToast('Slot created successfully');
    isLoading = false;
    notifyListeners();
    onSuccess?.call();
    nav.pop();
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }
}
