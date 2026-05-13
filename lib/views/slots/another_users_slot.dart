// another_users_slot_widget.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Renders a slot that is already booked by someone else.
// Displayed in red to signal unavailability. The occupant's name is shown
// only when the current user has visibility enabled in their settings.

import 'package:flutter/material.dart';
import 'package:consultation_app/models/slot_model.dart';
import 'package:consultation_app/setup.dart';
import 'slot_time.dart';

class AnotherUsersSlot extends StatelessWidget {
  final SlotModel slot;
  final int blockId;
  // Nullable: only provided in owner view to show the slot history button
  final Widget? Function(int slotId, int blockId, Color color)? showHistoryOption;
  final VoidCallback? onTap;
final bool canSeeIdentity;
  const AnotherUsersSlot({
    super.key,
    required this.slot,
    required this.blockId,
    required this.showHistoryOption,
    required this.onTap, required this.canSeeIdentity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
      width: MediaQuery.of(context).size.width * 0.95,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0),
        color: constants.red,
        border: Border.all(color: constants.grey, width: 0.2),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 6,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SlotTime(
                    time: slot.startTime,
                    color: constants.textUnavailableGrey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      canSeeIdentity
                          ? helpers.cropText(slot.takenByName ?? '')
                          : '',
                      style: TextStyle(
                        color: constants.textUnavailableGrey,
                        fontSize: constants.fsLabel,
                        fontWeight: constants.fwRegular,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      slot.note ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: constants.textUnavailableGrey,
                        fontSize: constants.fsLabel,
                        fontWeight: constants.fwRegular,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (showHistoryOption != null)
                    showHistoryOption!(slot.id, blockId, constants.background) ??
                        const SizedBox.shrink(),
                  if (slot.isOnline == 1) ...[
                    const SizedBox(width: 8),
                    svgs.icon("screen", constants.background),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
