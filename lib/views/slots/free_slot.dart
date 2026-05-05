import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:consultation_app/models/slot_model.dart';
import 'package:consultation_app/setup.dart';
import 'slot_time.dart';

class FreeSlot extends StatelessWidget {
  final SlotModel slot;
  final String date;
  final bool isTakingSlot;
  final int blockId;
  final Widget? Function(int slotId, int blockId, Color color)? showHistoryOption;
  final VoidCallback onTap;

  const FreeSlot({
    super.key,
    required this.slot,
    required this.date,
    required this.isTakingSlot,
    required this.blockId,
    required this.showHistoryOption,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isTakingSlot ? null : onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
        width: MediaQuery.of(context).size.width * 0.95,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SlotTime(time: slot.startTime, color: constants.darkGrey),
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
                        color: constants.darkGrey,
                        fontSize: constants.fsLabel,
                        fontWeight: constants.fwRegular,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (showHistoryOption != null)
                    showHistoryOption!(slot.id, blockId, constants.darkGrey) ??
                        const SizedBox.shrink(),
                  if (slot.isOnline == 1) ...[
                    const SizedBox(width: 8),
                    svgs.icon('screen', constants.darkGrey, width: constants.fsTitle),
                  ],
                  const SizedBox(width: 8),
                  isTakingSlot
                      ? SpinKitPouringHourGlass(
                          color: constants.primary,
                          size: constants.fsLabel,
                        )
                      : svgs.icon("add", constants.darkGrey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
