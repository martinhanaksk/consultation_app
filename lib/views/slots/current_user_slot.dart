// current_user_slot_widget.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Renders a slot booked by the current user.
// Displayed in the primary colour to distinguish it from other users' slots
// (red) and free slots. Includes a release button that warns the user when
// cancelling within the teacher-defined cancellation notice window.

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:consultation_app/models/slot_model.dart';
import 'package:consultation_app/setup.dart';
import 'slot_time.dart';

class CurrentUserSlot extends StatelessWidget {
  final SlotModel slot;
  final String date;
  // Hours before the slot start time after which a cancellation is considered impolite
  // set by the teacher per room
  final int cancellationNoticeHours;
  final int blockId;
  // True while the optimistic UI release is in progress (API call not yet confirmed)
  final bool isOptimisticallyReleased;
  // Nullable: only provided in owner view to show the slot history button
  final Widget? Function(int slotId, int blockId, Color color)? showHistoryOption;
  final VoidCallback onRelease;
  final VoidCallback onTap;

  const CurrentUserSlot({
    super.key,
    required this.slot,
    required this.date,
    required this.cancellationNoticeHours,
    required this.blockId,
    required this.isOptimisticallyReleased,
    required this.showHistoryOption,
    required this.onRelease,
    required this.onTap,
  });

  void _handleRelease(BuildContext context) {
    // The release is triggered immediately (optimistic update);
    // the warning dialog is purely informational and does not block the action
    onRelease();

    final DateTime slotStart = DateTime.parse('$date ${slot.startTime}');
    final Duration timeDifference = slotStart.difference(DateTime.now());

    // Shows warning only when cancelling inside the notice window
    // The slot is already released at this point regardless
    if (timeDifference.inHours < cancellationNoticeHours) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: constants.background,
            title: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: constants.fsBody,
                  color: constants.darkGrey,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: 'Warning!\n\n',
                    style: TextStyle(
                      fontSize: constants.fsHeadline,
                      fontWeight: constants.fwSemiBold,
                      color: constants.primary,
                    ),
                  ),
                  const TextSpan(
                    text:
                        'You are canceling this consultation very close to its start time.\n\n'
                        'Next time, please try to cancel at least ',
                  ),
                  // Selects between hour and hours based on number stored in cancellationNoticeHours
                  TextSpan(
                    text: cancellationNoticeHours == 1
                        ? '$cancellationNoticeHours hour'
                        : '$cancellationNoticeHours hours',
                    style: TextStyle(
                      fontWeight: constants.fwSemiBold,
                      color: constants.primary,
                    ),
                  ),
                  const TextSpan(text: ' in advance.'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => nav.pop(),
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontSize: constants.fsBody,
                    color: constants.primary,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
      width: MediaQuery.of(context).size.width * 0.95,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0),
        color: constants.primary,
        border: Border.all(color: constants.grey, width: 0.2),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SlotTime(time: slot.startTime, color: constants.background),
                const SizedBox(width: 12),
                Flexible(
                  flex: 2,
                  fit: FlexFit.loose,
                  child: Text(
                    // Mirrors the same visibility gate used in AnotherUsersSlot
                    sm.visibility == true
                        ? helpers.cropText(slot.takenByName ?? '')
                        : '',
                    style: TextStyle(
                      color: constants.background,
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
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    flex: 2,
                    fit: FlexFit.loose,
                    child: Text(
                      slot.note ?? '',
                      maxLines: 1,
                      style: TextStyle(
                        color: constants.background,
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
                    svgs.icon('screen', constants.background,
                        width: constants.fsTitle),
                  ],
                  const SizedBox(width: 8),
                  // The release button becomes a spinner while the optimistic
                  // update is pending, preventing a second tap
                  GestureDetector(
                    onTap: () => _handleRelease(context),
                    child: isOptimisticallyReleased
                        ? SpinKitPouringHourGlass(
                            color: constants.background,
                            size: constants.fsBody,
                          )
                        : svgs.icon("cross", constants.background),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
