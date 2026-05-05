import 'package:flutter/material.dart';
import 'package:consultation_app/models/slot_model.dart';
import 'package:consultation_app/setup.dart';
import 'slot_time.dart';

class AnotherUsersSlot extends StatelessWidget {
  final SlotModel slot;
  final int blockId;
  final Widget? Function(int slotId, int blockId, Color color)? showHistoryOption;
  final VoidCallback? onTap;

  const AnotherUsersSlot({
    super.key,
    required this.slot,
    required this.blockId,
    required this.showHistoryOption,
    required this.onTap,
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SlotTime(time: slot.startTime, color: constants.textUnavailableGrey),
                const SizedBox(width: 12),
                Flexible(
                  flex: 2,
                  fit: FlexFit.loose,
                  child: Text(
                    sm.visibility == true
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
