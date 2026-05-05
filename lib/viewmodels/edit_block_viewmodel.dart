import 'dart:convert';

import 'package:consultation_app/models/block_model.dart';
import 'package:consultation_app/models/slot_model.dart';
import 'package:consultation_app/setup.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

enum TimePickerAction { startTime, endTime, duration }

class EditBlockViewmodel extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────

  List<SlotModel> slots = [];
  BlockModel? block;
  String roomName = '';

  bool _isLoading = false;
  bool _isChecked = false;
  bool _disposed = false;
  int _roomId = 0;

  DateRangePickerSelectionMode _selectionMode =
      DateRangePickerSelectionMode.multiple;
  dynamic _selectedDates;

  // ── Getters ────────────────────────────────────────────────────────────────

  bool get isLoading => _isLoading;
  bool get isChecked => _isChecked;
  int get roomId => _roomId;
  DateRangePickerSelectionMode get selectionMode => _selectionMode;
  dynamic get selectedDates => _selectedDates;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  void init(int blockId, int roomId) {
    _roomId = roomId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshEditBlock(blockId);
    });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  // ── Public Methods ─────────────────────────────────────────────────────────

  void setSelectedDates(dynamic value) {
    _selectedDates = value;
    notifyListeners();
  }

  void setSelectionMode(DateRangePickerSelectionMode mode) {
    _selectionMode = mode;
    notifyListeners();
  }

  void refetchData(int? blockId) {
    if (blockId != null) fetchSlotsForBlock(blockId);
  }

  String getBlockDate() =>
      block != null ? helpers.getDateOnlySimple(block!.date) : '';

  List<String> getSelectedDatesIso() {
    if (_selectedDates == null) return [];

    switch (_selectionMode) {
      case DateRangePickerSelectionMode.multiple:
        return (_selectedDates as List<DateTime>).map(_formatDateIso).toList();

      case DateRangePickerSelectionMode.range:
        final range = _selectedDates as PickerDateRange;
        if (range.startDate == null) return [];
        return _expandDateRange(range.startDate!, range.endDate ?? range.startDate!);

      default:
        return [];
    }
  }

  Future<void> toggleIsOnline(bool? value, int blockId) async {
    final previous = _isChecked;
    _isChecked = value ?? false;
    notifyListeners();

    try {
      if (_isChecked) {
        await api.setBlockOnline(blockId);
      } else {
        await api.setBlockOffline(blockId);
      }
      notify.showToast('Block changed to ${value == true ? "online" : "offline"}');
    } catch (_) {
      _isChecked = previous;
      notifyListeners();
      notify.showToast('Add slots first');
    }

    refreshEditBlock(blockId);
  }

  Future<void> copyBlock(int roomId) async {
    final dates = getSelectedDatesIso();
    if (dates.isEmpty) {
      notify.showToast('Please select at least one date');
      return;
    }

    _setLoading(true);

    try {
      for (final date in dates) {
        final response = await api.createBlock(roomId, date);
        if (response.isEmpty) {
          notify.showToast('Failed to create block for $date', isError: true);
          continue;
        }

        final blockId = jsonDecode(response)['id'] as int;
        final success = await _copySlots(blockId);
        if (!success) return;
      }
      notify.showToast('Blocks copied successfully');
    } catch (_) {
      notify.showToast('Error while copying', isError: true);
    } finally {
      _setLoading(false);
    }

    nav.pop();
  }

  Future<void> deleteBlock(int blockId) async {
    final previousBlock = block;
    final previousSlots = List<SlotModel>.from(slots);

    block = null;
    slots.clear();
    notifyListeners();

    try {
      final deleted = await api.deleteBlock(blockId);
      if (deleted) {
        notify.showToast('Block was deleted successfully');
      } else {
        _restoreBlock(previousBlock, previousSlots);
        notify.showToast('Block could not be deleted');
      }
    } catch (_) {
      _restoreBlock(previousBlock, previousSlots);
      notify.showToast('Error while deleting block', isError: true);
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
    } catch (_) {
      slots[index] = original;
      notifyListeners();
      notify.showToast('Error while changing consultation type', isError: true);
    }
  }

  Future<void> deleteSlot(int slotId) async {
    final index = slots.indexWhere((s) => s.id == slotId);
    if (index == -1) return;

    final removed = slots[index];
    slots.removeAt(index);
    notifyListeners();

    try {
      final deleted = await api.deleteSlot(slotId);
      if (!deleted) {
        slots.insert(index, removed);
        notifyListeners();
        notify.showToast('Error while deleting slot', isError: true);
      }
    } catch (_) {
      slots.insert(index, removed);
      notifyListeners();
      notify.showToast('Error while deleting slot', isError: true);
    }
  }

  Future<void> refreshEditBlock(int blockId) async {
    _setLoading(true);
    await assignBlock(blockId, _roomId);
    await fetchSlotsForBlock(blockId);
    roomName = await _fetchRoomName(_roomId);
    if (block != null) _isChecked = block!.isOnline == 1;
    _setLoading(false);
  }

  Future<void> assignBlock(int blockId, int roomId) async {
    _setLoading(true);
    try {
      final blocks = await api.getBlocks(roomId);
      block = blocks.firstWhere((b) => b.id == blockId);
    } catch (_) {
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchSlotsForBlock(int blockId) async {
    _setLoading(true);
    try {
      final fetched = await api.getSlotsForBlock(blockId, _todayString());
      slots = fetched ?? [];
      slots.sort((a, b) => a.startTime.compareTo(b.startTime));
    } catch (_) {
      slots = [];
    } finally {
      _setLoading(false);
    }
  }

  // ── Private Helpers ────────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _todayString() => DateTime.now().toString().substring(0, 10);

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

  void _restoreBlock(BlockModel? previousBlock, List<SlotModel> previousSlots) {
    block = previousBlock;
    slots = previousSlots;
    notifyListeners();
  }

  Future<String> _fetchRoomName(int roomId) async {
    try {
      final rooms = await api.getAllRooms();
      return rooms.firstWhere((r) => r.id == roomId).title;
    } catch (_) {
      return 'error';
    }
  }

  Future<bool> _copySlots(int blockId) async {
    for (int i = 0; i < slots.length; i++) {
      final slot = slots[i];
      final success = await api.createSlot(
        blockId,
        slot.startTime,
        slot.duration,
        slot.isOnline,
        slot.note ?? '',
      );
      if (!success) {
        notify.showToast('Failed to create slot $i for block $blockId', isError: true);
        _setLoading(false);
        return false;
      }
    }
    return true;
  }
}
