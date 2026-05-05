// slot_widget.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Dispatcher widget that selects the correct slot variant to render based on
// slot's booking state and the viewer's identity:
//   - FreeSlot:          unbooked or optimistically released
//   - CurrentUserSlot:   booked by the logged-in user
//   - AnotherUsersSlot:  booked by someone else
// Also owns the two bottom sheets (take slot, change consultation type).

import 'package:flutter/material.dart';
import 'package:consultation_app/models/slot_model.dart';
import 'package:consultation_app/setup.dart';
import 'free_slot.dart';
import 'current_user_slot.dart';
import 'another_users_slot.dart';
import 'take_slot_bottom_sheet.dart';
import 'type_bottom_sheet.dart';

class SlotWidget extends StatelessWidget {
  final String visitReason;
  final SlotModel slot;
  final int cancellationNoticeHours;
  final int blockId;
  // 1 = teacher viewing their own room; unlocks the change-type tap on taken slots
  final int isOwnerView;
  // Nullable: only provided in owner view to show the slot history button
  final Widget? Function(int slotId, int blockId, Color color)?
  showHistoryOption;
  final void Function(String note, int isOnline) onTakeSlot;
  final VoidCallback onReleaseSlot;
  final VoidCallback onChangeConsultationType;
  final BuildContext context;
  // True while a booking API call is in progress (optimistic update pending)
  final bool isTakingSlot;
  final bool isOptimisticallyReleased;

  final bool isFirst;
  final bool isLast;
  final String date;

  const SlotWidget({
    super.key,
    required this.visitReason,
    required this.slot,
    required this.cancellationNoticeHours,
    required this.blockId,
    required this.showHistoryOption,
    required this.isOwnerView,
    required this.onTakeSlot,
    required this.isOptimisticallyReleased,
    required this.isTakingSlot,
    required this.onReleaseSlot,
    required this.onChangeConsultationType,
    required this.context,
    required this.isFirst,
    required this.isLast,
    required this.date,
  });

  Future<void> _showTakeSlotDialog(
    BuildContext context,
    String startTime,
    int duration,
    String date,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: constants.transparent,
      builder: (context) => TakeSlotBottomSheet(
        visitReason: visitReason,
        startTime: startTime,
        // isOnline == 0 means in-person; converting the int flag to bool for the sheet
        isOnline: slot.isOnline == 0 ? false : true,
        isOnlineTeacher: slot.isOnlineTeacher == 0 ? false : true,
        duration: duration,
        date: date,
        onTakeSlot: onTakeSlot,
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  Future<void> _showChangeConsultationTypeDialog(
    BuildContext context,
    String name,
    int isOnline,
    int isOnlineTeacher,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: constants.transparent,
      builder: (context) => ConsultationTypeBottomSheet(
        isOnline: isOnline,
        isOnlineTeacher: isOnlineTeacher,
        name: name,
        onChangeConsultationType: onChangeConsultationType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // A slot is considered free if it has no owner OR if the local release is
    // still pending (optimistic UI). The server will confirm asynchronously
    final bool isFree = slot.takenBy == null || isOptimisticallyReleased;
    final bool isMySlot = !isFree && slot.takenBy == sm.email;
    final bool isSomeonesSlot = !isFree && !isMySlot;
    final bool canSeeIdentity = sm.visibility == true;

    if (isFree) {
      return FreeSlot(
        slot: slot,
        date: date,
        isTakingSlot: isTakingSlot,
        showHistoryOption: showHistoryOption,
        blockId: blockId,
        onTap: () =>
            _showTakeSlotDialog(context, slot.startTime, slot.duration, date),
      );
    }

    if (isMySlot) {
      return CurrentUserSlot(
        slot: slot,
        date: date,
        cancellationNoticeHours: cancellationNoticeHours,
        showHistoryOption: showHistoryOption,
        blockId: blockId,
        isOptimisticallyReleased: isOptimisticallyReleased,
        onRelease: onReleaseSlot,
        onTap: () => _showChangeConsultationTypeDialog(
          context,
          // Name is passed only when the viewer has visibility enabled
          canSeeIdentity ? (slot.takenByName ?? "") : "",
          slot.isOnline,
          slot.isOnlineTeacher,
        ),
      );
    }

    if (isSomeonesSlot) {
      return AnotherUsersSlot(
        slot: slot,
        showHistoryOption: showHistoryOption,
        blockId: blockId,
        // Only the room owner can tap a taken slot to change its consultation type
        onTap: isOwnerView == 1
            ? () => _showChangeConsultationTypeDialog(
                context,
                canSeeIdentity ? (slot.takenByName ?? "") : "",
                slot.isOnline,
                slot.isOnlineTeacher,
              )
            : null,
      );
    }

    // Unreachable in practice. All three states are covered above
    return const SizedBox.shrink();
  }
}
