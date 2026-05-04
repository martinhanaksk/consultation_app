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
  int _roomId =0;
  int get roomId => _roomId;
  bool get isLoading => _isLoading;
  BlockModel? block;
  DateRangePickerSelectionMode _selectionMode =
      DateRangePickerSelectionMode.multiple;
  DateRangePickerSelectionMode get selectionMode => _selectionMode;
  dynamic _selectedDates;
  dynamic get selectedDates => _selectedDates;
  bool _isChecked = false;
  bool get isChecked => _isChecked;
  Future<void> toggleIsOnline(bool? value, int blockId) async {
    final bool previousState = _isChecked;
    _isChecked = value ?? false;
    notifyListeners();
    try {
      if (_isChecked) {
        await api.setBlockOnline(blockId);
      } else {
        await api.setBlockOffline(blockId);
      }
      notify.showToast(
        "Block changed to " + (value == true ? "online" : "offline"),
      );
    } catch (e) {
      _isChecked = previousState;
      notifyListeners();
      notify.showToast("Add slots first");
    }
    refreshEditBlock(blockId);
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

  Future<void> copyBlock(int roomId) async {
    List<String> dates = getSelectedDatesIso();

    if (dates.isEmpty) {
      notify.showToast('Please select at least one date');
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final slotCount = slots.length;

      for (int i = 0; i < dates.length; i++) {
        String response = await api.createBlock(roomId, dates[i]);
        if (response.isEmpty) {
          notify.showToast('Failed to create block for ${dates[i]}',isError: true);
          continue;
        }
        final int blockId = jsonDecode(response)['id'];
        if (slotCount != 0) {
          for (int j = 0; j < slotCount; j++) {
            bool success = await api.createSlot(
              blockId,
              slots[j].startTime,
              slots[j].duration,
              slots[j].isOnline,
              slots[j].note ?? "",
            );
            if (!success) {
              notify.showToast('Failed to create slot $j for block $blockId',isError: true);
              _isLoading = false;
              notifyListeners();
              return;
            }
          }
        }
      }
      notify.showToast('Blocks copied successfully');
    } catch (e) {
      notify.showToast('Error while copying',isError: true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    nav.pop();
  }

  Future<void> deleteBlock(int blockId) async {
    final BlockModel? previousBlock = block;
    final List<SlotModel> previousSlots = List.from(slots);

    block = null;
    slots.clear();
    notifyListeners();

    try {
      bool deleted = await api.deleteBlock(blockId);
      if (deleted) {
        notify.showToast("Block was deleted successfully");
      } else {
        block = previousBlock;
        slots = previousSlots;
        notifyListeners();
        notify.showToast("Block could not be deleted");
      }
    } catch (e) {
      block = previousBlock;
      slots = previousSlots;
      notifyListeners();
      notify.showToast("Error while deleting block",isError: true);
    }
  }

  void refetchData(int? blockId) {
    if (blockId != null) {
      fetchSlotsForBlock(blockId);
    }
  }

  Future<void> changeSlotMeetingType(int slotId) async {
    final index = slots.indexWhere((s) => s.id == slotId);
    if (index == -1) return;

    final original = slots[index];
    slots[index] = SlotModel(
      id: original.id,
      blockId: original.blockId,
      roomId: original.roomId,
      startTime: original.startTime,
      duration: original.duration,
      isOnline: original.isOnline == 0 ? 1 : 0,
       isOnlineTeacher: original.isOnlineTeacher,
      note: original.note,
      takenBy: original.takenBy,
      takenByName: original.takenByName,
      takenByReason: original.takenByReason,
      history: original.history,
    );
    notifyListeners();

    try {
      await api.changeConsultationType(slotId);
      notify.showToast('Consultation type was successfully changed');
    } catch (e) {
      slots[index] = original;
      notifyListeners();
      notify.showToast('Error while changing consultation type',isError: true);
    }
  }

  Future<void> deleteSlot(int slotId) async {
    final removedSlot = slots.firstWhere((s) => s.id == slotId);
    final removedIndex = slots.indexOf(removedSlot);
    slots.removeWhere((s) => s.id == slotId);
    notifyListeners();

    try {
      bool b = await api.deleteSlot(slotId);
      if (!b) {
        slots.insert(removedIndex, removedSlot);
        notifyListeners();
        notify.showToast('Error while deleting slot',isError: true);
      }
    } catch (e) {
      slots.insert(removedIndex, removedSlot);
      notifyListeners();
      notify.showToast('Error while deleting slot',isError: true);
    }
  }

  void refreshEditBlock(int blockId) async {
    _isLoading = true;
    notifyListeners();
    await assignBlock(blockId, _roomId);
    await fetchSlotsForBlock(blockId);
    roomName = await getRoomNameById(_roomId);
    if (block != null) {
      _isChecked = block!.isOnline == 1 ? true : false;
    }
    _isLoading = false;
    notifyListeners();
  }

  void init(int blockId, int roomId) async {
    _roomId = roomId;
     WidgetsBinding.instance.addPostFrameCallback((_) {
    refreshEditBlock(blockId);
  });
  }

  Future<String> getRoomNameById(int roomId) async {
    try {
      final rooms = await api.getAllRooms();
      final room = rooms.firstWhere((r) => r.id == roomId);
      return room.title;
    } catch (e) {
      return "error";
    }
  }

  Future<void> assignBlock(int blockId, int roomId) async {
    _isLoading = true;
    notifyListeners();
    try {
      String now = DateTime.now().toString().substring(0, 10);
      final blocks = await api.getBlocks(roomId);
      block = blocks.firstWhere((b) => b.id == blockId);
    } catch (e) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String getBlockDate() {
    if (block != null) {
      return helpers.getDateOnlySimple(block!.date);
    } else {
      return "";
    }
  }

  Future<void> fetchSlotsForBlock(int blockId) async {
    _isLoading = true;
    notifyListeners();
    try {
      String now = DateTime.now().toString().substring(0, 10);
      final tmpSlots = await api.getSlotsForBlock(blockId,now);
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
   bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }  
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }
}

enum TimePickerAction { startTime, endTime, duration }
