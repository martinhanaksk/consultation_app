import 'package:consultation_app/setup.dart';
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

  String _formatTimeWithSeconds(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    const seconds = '00';
    return '$hours:$minutes:$seconds';
  }

  String? validateCreate() {
    if (_startTime == null) return 'Please set a start time';
    if (_duration == null || _duration!.inMinutes == 0) {
      return 'Please set a duration';
    }
    return null;
  }

  void addSlot(
    String blockId,
    VoidCallback? onSuccess,
  ) async {
    isLoading = true;
    notifyListeners();

    final error = validateCreate();
    if (error != null) {
      notify.showToast(error);
      isLoading = false;
      notifyListeners();
      return;
    }

    final String startTimeStr = _formatTimeWithSeconds(_startTime!);
    final int durationMinutes = _duration!.inMinutes;
    final int isOnlineInt = _isOnline ? 1 : 0;
    final String note = noteController.text.trim();

    final bool success = await api.createSlot(
      int.parse(blockId),
      startTimeStr,
      durationMinutes,
      isOnlineInt,
      note,
    );

    if (!success) {
      notify.showToast('Failed to create slot.');
      isLoading = false;
      notifyListeners();
      return;
    }

    notify.showToast('Slot created successfully.');
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
