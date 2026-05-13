// base_consultations_viewmodel.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Core ViewModel shared by both the student and owner consultation views.
// Manages room selection, block/slot loading, optimistic UI updates for
// take/release actions, email subscriptions and website launching.

import 'package:consultation_app/models/block_model.dart';
import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/models/slot_model.dart';
import 'package:consultation_app/setup.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

enum ViewMode { visitor, owner }

class BaseConsultationsViewModel extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────
  bool isOwner = false;
  bool _disposed = false;
  bool isLoading = false;
  bool blocksFiltered = false;
  bool noRoomsFound = false;
  List<int> subscribedBlocks = [];
  List<RoomModel>? rooms = [];
  List<BlockModel> blocks = [];
  Map<int, List<SlotModel>?> slotsInBlocks = {};
  int? ownerSelectedRoomId;
  int? visitorSelectedRoomId;
  int? selectedRoomId;
  bool _isWebsiteLoading = false;
  String _visitReason = '';
  // 0 = visitor/student view, 1 = owner view
  int _ownerView = 1;
  // Per-block and per-slot loading flags stored as maps so only the
  // affected item triggers rebuild
  final Map<int, bool> _addingSlotBefore = {};
  final Map<int, bool> _addingSlotAfter = {};
  final Map<int, bool> _slotLoading = {};
  final Map<int, bool> _optimisticallyReleased = {};
  final Map<int, bool> _takingSlot = {};
  bool? isConnected;
  // ── Getters ────────────────────────────────────────────────────────────────
  bool get isWebsiteLoading => _isWebsiteLoading;
  String get visitReason => _visitReason;
  int get ownerView => _ownerView;
  String? get currentUserEmail => sm.email;
  bool get canSeeIdentity => sm.visibility == true;
  bool get isTeacher => sm.role == 'teacher';
  bool isAddingSlotBefore(int blockId) => _addingSlotBefore[blockId] ?? false;
  bool isAddingSlotAfter(int blockId) => _addingSlotAfter[blockId] ?? false;
  bool isSlotLoading(int slotId) => _slotLoading[slotId] ?? false;
  bool isOptimisticallyReleased(int slotId) =>
      _optimisticallyReleased[slotId] ?? false;
  bool isTakingSlot(int slotId) => _takingSlot[slotId] ?? false;

  // Returns the correct selected room ID for the current view mode
  int? get roomIdNumber =>
      ownerView == 0 ? visitorSelectedRoomId : ownerSelectedRoomId;

  // Guards against a selectedRoomId that no longer exists in the rooms list
  int? get safeSelectedRoomId {
    if (rooms == null || selectedRoomId == null) return null;
    return rooms!.any((r) => r.id == selectedRoomId) ? selectedRoomId : null;
  }

  // Returns null instead of throwing if the selected room has been removed
  RoomModel? get selectedRoom {
    if (rooms == null || rooms!.isEmpty || selectedRoomId == null) return null;
    try {
      return rooms!.firstWhere((r) => r.id == selectedRoomId);
    } catch (_) {
      return null;
    }
  }

  // ── Public Methods ─────────────────────────────────────────────────────────
  Future<void> init() async {
    noRoomsFound = false;
    isConnected = null;
    final email = sm.email;

    setLoading(true);

    try {
      if (!await checkConnection()) return;
      await setOwnerView(0);
      sm.checkIfValidToken();
      isOwner = await resolveUserRole(email);
      _visitReason = sm.visitReason;
      subscribedBlocks = await api.getMySubscriptions();
      final myRooms = await fetchRooms();
      if (myRooms.isEmpty) {
        noRoomsFound = true;
        return;
      }

      // Restore the last visited room from session
      visitorSelectedRoomId = sm.roomIdVisitor ?? myRooms.first.id;
      selectedRoomId = visitorSelectedRoomId;
      await refreshRoomData(selectedRoomId!);
    } catch (_) {
      notify.showToast(
        'Failed to load consultations. Please check your internet connection.',
        isError: true,
      );
    } finally {
      setLoading(false);
    }
  }

  Future<void> loadRoom() async {
    sm.checkIfValidToken();
    if (roomIdNumber != null) {
      await refreshRoomData(roomIdNumber!);
    }
  }

  Future<void> refreshRoomData(int roomId) async {
    setLoading(true);

    try {
      if (!await checkConnection()) return;
      List<int> subscriptions = [];
      try {
        subscriptions = await api.getMySubscriptions();
      } catch (_) {
        notify.showToast('Could not load your subscriptions', isError: true);
      }
      final newRooms = await fetchRooms();
      _visitReason = sm.visitReason;
      if (newRooms.isEmpty) {
        noRoomsFound = true;
        notifyListeners();
        return;
      }
      noRoomsFound = false;

      // Only fetch blocks from today onward to avoid showing past consultations
      final today = _todayString();
      final newBlocks = await api.getBlocks(roomId, today);
      final newSlotsInBlocks = await _fetchSlotsForBlocks(newBlocks);

      // Assign all fetched data
      subscribedBlocks = subscriptions;
      rooms = newRooms;
      blocks = newBlocks;
      slotsInBlocks = newSlotsInBlocks;
      blocksFiltered = true;
    } finally {
      setLoading(false);
    }
  }

  Future<void> takeSlot(int slotId, String note, int isOnline) async {
    _takingSlot[slotId] = true;
    notifyListeners();

    // Optimistically mark the slot as taken in the local cache so the UI
    // responds immediately before the API call completes
    final oldSlot = _findSlot(slotId);
    if (oldSlot != null) {
      _updateSlotInCache(
        slotId,
        SlotModel(
          id: oldSlot.id,
          blockId: oldSlot.blockId,
          roomId: oldSlot.roomId,
          startTime: oldSlot.startTime,
          duration: oldSlot.duration,
          isOnline: oldSlot.isOnline,
          isOnlineTeacher: oldSlot.isOnlineTeacher,
          note: oldSlot.note,
          takenBy: sm.email,
          takenByName: sm.name,
          takenByReason: note,
          history: oldSlot.history,
        ),
      );
    }
    try {
      await api.takeSlot(slotId, note, isOnline);
      await _refreshSlotsForBlock(slotId);
    } catch (_) {
      // Roll back the optimistic update on failure
      if (oldSlot != null) _updateSlotInCache(slotId, oldSlot);
      notify.showToast('Failed to take slot', isError: true);
    } finally {
      _takingSlot.remove(slotId);
      notifyListeners();
    }
  }

  Future<void> releaseSlot(int slotId) async {
    _optimisticallyReleased[slotId] = true;
    notifyListeners();

    // Optimistically clear the booking fields in the local cache
    final oldSlot = _findSlot(slotId);
    if (oldSlot != null) {
      _updateSlotInCache(
        slotId,
        SlotModel(
          id: oldSlot.id,
          blockId: oldSlot.blockId,
          roomId: oldSlot.roomId,
          startTime: oldSlot.startTime,
          duration: oldSlot.duration,
          isOnline: oldSlot.isOnline,
          isOnlineTeacher: oldSlot.isOnlineTeacher,
          note: oldSlot.note,
          takenBy: null,
          takenByName: null,
          takenByReason: null,
          history: oldSlot.history,
        ),
      );
    }
    try {
      await api.releaseSlot(slotId);
      await _refreshSlotsForBlock(slotId);
    } catch (_) {
      // Roll back the optimistic update on failure
      if (oldSlot != null) _updateSlotInCache(slotId, oldSlot);
      notify.showToast('Failed to release slot', isError: true);
    } finally {
      _optimisticallyReleased.remove(slotId);
      notifyListeners();
    }
  }

  Future<void> onChangeConsultationType(int slotId) async {
    setLoading(true);

    // Optimistically flip the isOnline flag before the API responds
    final oldSlot = _findSlot(slotId);
    if (oldSlot != null) {
      _updateSlotInCache(
        slotId,
        SlotModel(
          id: oldSlot.id,
          blockId: oldSlot.blockId,
          roomId: oldSlot.roomId,
          startTime: oldSlot.startTime,
          duration: oldSlot.duration,
          isOnline: oldSlot.isOnline == 0 ? 1 : 0,
          isOnlineTeacher: oldSlot.isOnlineTeacher,
          note: oldSlot.note,
          takenBy: oldSlot.takenBy,
          takenByName: oldSlot.takenByName,
          takenByReason: oldSlot.takenByReason,
          history: oldSlot.history,
        ),
      );
    }
    try {
      await api.changeConsultationType(slotId);
      await _refreshSlotsForBlock(slotId);
    } catch (_) {
      if (oldSlot != null) _updateSlotInCache(slotId, oldSlot);
      notify.showToast('Slot cannot be manipulated');
    } finally {
      setLoading(false);
    }
  }

  Future<void> handleEmailSubscribe(int blockId) async {
    // Optimistically toggle the local list so the bell icon flips instantly
    final wasSubscribed = subscribedBlocks.contains(blockId);
    _toggleSubscription(blockId, subscribe: !wasSubscribed);
    try {
      await api.subscribeToBlock(blockId);
      // Re-fetch to stay in sync
      subscribedBlocks = await api.getMySubscriptions();
      notifyListeners();
    } catch (_) {
      // Roll back the optimistic toggle on failure
      _toggleSubscription(blockId, subscribe: wasSubscribed);
      notify.showToast(
        'Failed to update subscription, please try again later',
        isError: true,
      );
    }
  }

  Future<void> switchRoom(int newRoomId) async {
    // Persist the selection in the correct slot depending on the active view mode
    if (_ownerView == 1) {
      ownerSelectedRoomId = newRoomId;
    } else {
      visitorSelectedRoomId = newRoomId;
    }
    selectedRoomId = roomIdNumber;
    await loadRoom();
  }

  Future<bool> validateAndSelectRoom(int? id) async {
    if (id == null) return false;

    // Re-fetch rooms to ensure the user still has access to the target room
    final myRooms = await fetchRooms();
    if (!myRooms.any((room) => room.id == id)) {
      notify.showToast('Invalid room or access denied', isError: true);
      return false;
    }

    // Persist the selection in session storage
    if (ownerView == 0) {
      visitorSelectedRoomId = id;
      sm.setRoomIdVisitor(id);
    } else {
      ownerSelectedRoomId = id;
      sm.setRoomIdOwner(id);
    }
    selectedRoomId = id;
    notifyListeners();
    return true;
  }

  Future<void> launchWebsite(String url) async {
    // Guard against double-taps triggering a second launch while the first is pending
    if (_isWebsiteLoading) return;

    final normalized = _normalizeUrl(url.trim());
    if (normalized == null) {
      notify.showToast('URL is empty');
      return;
    }
    _isWebsiteLoading = true;
    notifyListeners();
    try {
      final uri = Uri.parse(normalized);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        notify.showToast('Could not launch $normalized', isError: true);
      }
    } catch (_) {
      notify.showToast('Could not launch $normalized', isError: true);
    } finally {
      _isWebsiteLoading = false;
      notifyListeners();
    }
  }

  Future<void> setOwnerView(int value) async {
    if (_ownerView == value) return;
    _ownerView = value;
    notifyListeners();
  }

  void setAddingSlotBefore(int blockId, bool value) {
    _addingSlotBefore[blockId] = value;
    notifyListeners();
  }

  void setAddingSlotAfter(int blockId, bool value) {
    _addingSlotAfter[blockId] = value;
    notifyListeners();
  }

  Future<List<RoomModel>> fetchRooms() => api.getJoinedRooms();
  Future<bool> checkConnection() async {
    final online = await helpers.handleIsInternetConnection();
    isConnected = online;
    notifyListeners();
    if (online) {
      return true;
    }

    notify.showToast(
      'Please check your internet connection and try again',
      isError: true,
    );
    setLoading(false);
    rooms = [];
    blocks = [];
    slotsInBlocks = {};
    ownerSelectedRoomId = null;
    visitorSelectedRoomId = null;
    selectedRoomId = null;
    noRoomsFound = true;
    notifyListeners();
    return false;
  }

  Future<bool> resolveUserRole(String email) async {
    try {
      return await api.getRole() == 'teacher';
    } catch (_) {
      return false;
    }
  }

  int getBlocksCount() =>
      blocksFiltered && blocks.isNotEmpty ? blocks.length : 0;
  String blockDateLabel(int blockId) {
    final block = _findBlock(blockId);
    if (block == null) return '';
    final date = DateTime.parse(block.date.toString());
    return '${helpers.getDateOnlySimple(date)} ${daysRemainingLabel(block.date)}';
  }

  String blockDate(int blockId) {
    final block = _findBlock(blockId);
    return block != null ? '${DateTime.parse(block.date.toString())}' : '';
  }

  // Returns a human-readable relative label: empty for past dates, "today",
  // "tomorrow", or "N d." for dates further in the future
  String daysRemainingLabel(DateTime date) {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;
    if (diff < 0) return '';
    if (diff == 0) return '(today)';
    if (diff == 1) return '(tomorrow)';
    return '($diff d.)';
  }

  // ── Private Helpers ────────────────────────────────────────────────────────
  void setLoading(bool value) {
    if (_disposed) return;
    isLoading = value;
    notifyListeners();
  }

  // Returns date portion of DateTime.now() as "yyyy-MM-dd"
  String _todayString() => DateTime.now().toString().substring(0, 10);

  // Prepends "https://" when the URL has no scheme, rejects empty strings
  String? _normalizeUrl(String trimmed) {
    if (trimmed.isEmpty) return null;
    return trimmed.startsWith('http://') || trimmed.startsWith('https://')
        ? trimmed
        : 'https://$trimmed';
  }

  void _toggleSubscription(int blockId, {required bool subscribe}) {
    if (subscribe) {
      subscribedBlocks.add(blockId);
    } else {
      subscribedBlocks.remove(blockId);
    }
    notifyListeners();
  }

  // Fetches slots for all blocks in parallel using Future.wait
  Future<Map<int, List<SlotModel>?>> _fetchSlotsForBlocks(
    List<BlockModel> blockList,
  ) async {
    final result = <int, List<SlotModel>>{};
    final today = _todayString();

    await Future.wait(
      blockList.map((block) async {
        final slots = await api.getSlotsForBlock(block.id, today);
        result[block.id] = slots ?? [];
      }),
    );
    return result;
  }

  BlockModel? _findBlock(int blockId) {
    try {
      return blocks.firstWhere((b) => b.id == blockId);
    } catch (_) {
      return null;
    }
  }

  SlotModel? _findSlot(int slotId) {
    for (final slots in slotsInBlocks.values) {
      if (slots == null) continue;
      try {
        return slots.firstWhere((s) => s.id == slotId);
      } catch (_) {}
    }
    return null;
  }

  int? _findBlockIdForSlot(int slotId) {
    for (final entry in slotsInBlocks.entries) {
      if (entry.value?.any((s) => s.id == slotId) ?? false) {
        return entry.key;
      }
    }
    return null;
  }

  void _updateSlotInCache(int slotId, SlotModel updatedSlot) {
    final blockId = _findBlockIdForSlot(slotId);
    if (blockId == null) return;
    final slots = slotsInBlocks[blockId];
    if (slots == null) return;
    final index = slots.indexWhere((s) => s.id == slotId);
    if (index != -1) {
      slots[index] = updatedSlot;
      notifyListeners();
    }
  }

  Future<void> _refreshSlotsForBlock(int slotId) async {
    final blockId = _findBlockIdForSlot(slotId);
    if (blockId == null) return;
    try {
      final freshSlots = await api.getSlotsForBlock(blockId, _todayString());
      if (freshSlots != null) {
        slotsInBlocks[blockId] = freshSlots;
        notifyListeners();
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // Overridden to guard against async callbacks firing after dispose()
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }
}
