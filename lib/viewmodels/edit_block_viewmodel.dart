import 'package:consultation_app/models/block_model.dart';
import 'package:consultation_app/models/slot_model.dart';
import 'package:consultation_app/setup.dart';
import 'package:flutter/material.dart';

class EditBlockViewmodel extends ChangeNotifier {
  List<SlotModel> slots = [];
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  BlockModel? block;
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
        nav.toDisplaySlotHistory(history: slot.history??"");
      }
    } finally {
    }
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
