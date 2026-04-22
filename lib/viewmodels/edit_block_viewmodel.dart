import 'dart:convert';

import 'package:consultation_app/models/block_model.dart';
import 'package:consultation_app/models/slot_model.dart';
import 'package:consultation_app/setup.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class EditBlockViewmodel extends ChangeNotifier {
  List<SlotModel> slots = [];
  bool _isLoading = false;
  String roomName = "";
  bool get isLoading => _isLoading;
  BlockModel? block;
  DateRangePickerSelectionMode _selectionMode =
      DateRangePickerSelectionMode.multiple;
  DateRangePickerSelectionMode get selectionMode => _selectionMode;
  dynamic _selectedDates;
  dynamic get selectedDates => _selectedDates;
  bool _isChecked = false;
  bool get isChecked => _isChecked;
  Future<void> toggleIsOnline(bool? value, String token, int blockId) async {
    _isChecked = value ?? false;
    if (_isChecked) {
      await api.setBlockOnline(token, blockId);
    } else {
      await api.setBlockOffline(token, blockId);
    }
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

  String _formatDateIso(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
  List<String> _expandDateRange(DateTime start, DateTime end) {
    final List<String> dates = [];
    DateTime current = start;
    while (!current.isAfter(end)) {
      dates.add(_formatDateIso(current));
      current = current.add(const Duration(days: 1));
    }
    return dates;
  }

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

  Future<void> copyBlock(String token, String roomId) async {
    List<String> dates = getSelectedDatesIso();

    if (dates.isEmpty) {
      notify.showToast('Please select at least one date.');
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final slotCount = slots.length;

      for (int i = 0; i < dates.length; i++) {
        String response = await api.createBlock(
          token,
          int.parse(roomId),
          dates[i],
        );
        if (response.isEmpty) {
          notify.showToast('Failed to create block for ${dates[i]}.');
          continue;
        }
        final int blockId = jsonDecode(response)['id'];
        if (slotCount != 0) {
          for (int j = 0; j < slotCount; j++) {
            bool success = await api.createSlot(
              token,
              blockId,
              slots[j].startTime,
              slots[j].duration,
              slots[j].isOnline,
              slots[j].note ?? "",
            );
            if (!success) {
              notify.showToast('Failed to create slot $j for block $blockId');
              _isLoading = false;
              notifyListeners();
              return;
            }
          }
        }
      }
      notify.showToast('Blocks copied successfully.');
    } catch (e) {
      notify.showToast('An unexpected error occurred while copying.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    nav.pop();
  }

  Future<void> deleteBlock(String token, String blockId) async {
    bool deleted = await api.deleteBlock(token, int.parse(blockId));
    if (deleted) {
      notify.showToast("Block was deleted successfully.");
    } else {
      notify.showToast("Block could not be deleted.");
    }
  }

  void refetchData(String? token, String? blockId) {
    if (token != null && blockId != null) {
      fetchSlotsForBlock(token, blockId);
    }
  }

  Future<void> changeSlotMeetingType(String token, int slotId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await api.changeConsultationType(token, slotId);
      notify.showToast('Consultation type was successfully changed.');
    } catch (e) {
      notify.showToast('Error while changing consultation type.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSlot(String token, int slotId) async {
    _isLoading = true;
    notifyListeners();
    try {
      bool b = await api.deleteSlot(token, slotId);
      if (b) {
        slots.removeWhere((s) => s.id == slotId);
        notify.showToast('Slot was successfully deleted.');
      }
    } catch (e) {
      notify.showToast('Error while deleting slot.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void init(String token, String blockId, String roomId) async {
    await assignBlock(token, int.parse(blockId), int.parse(roomId));
    await fetchSlotsForBlock(token, blockId);
    roomName = await getRoomNameById(token, int.parse(roomId));
    if (block != null) {
      _isChecked = block!.isOnline == 1 ? true : false;
    }
    notifyListeners();
  }

  Future<String> getRoomNameById(String token, int roomId) async {
    try {
      final rooms = await api.getAllRooms(token);
      final room = rooms.firstWhere((r) => r.id == roomId);
      return room.title;
    } catch (e) {
      return "error";
    }
  }

  Future<void> assignBlock(String token, int blockId, int roomId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final blocks = await api.getBlocks(token, roomId);
      block = blocks.firstWhere((b) => b.id == blockId);
    } catch (e) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> displayHistoryOfSlot(
    String token,
    int slotId,
    int blockId,
  ) async {
    try {
      final slots = await api.getSlotsForBlock(token, blockId);
      if (slots != null) {
        final slot = slots.firstWhere((s) => s.id == slotId);
        nav.toDisplaySlotHistory(history: slot.history ?? "");
      }
    } finally {}
  }

  String getBlockDate() {
    if (block != null) {
      return helpers.getTDateOnlySimple(block!.date);
    } else {
      return "";
    }
  }

  Future<void> fetchSlotsForBlock(String token, String blockId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final tmpSlots = await api.getSlotsForBlock(token, int.parse(blockId));
      if (tmpSlots != null) {
        tmpSlots.sort((a, b) => a.startTime.compareTo(b.startTime));
        slots = tmpSlots;
      } else {
        slots = [];
      }
    } catch (e) {
      slots = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

enum TimePickerAction { startTime, endTime, duration }
