import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:consultation_app/models/slot_model.dart';
import 'package:consultation_app/setup.dart';
import 'package:figma_squircle/figma_squircle.dart';

class SlotWidget extends StatelessWidget {
  final String userEmail;
  final SlotModel slot;
  final String token;
  final String roomId;
  final void Function(String note) onTakeSlot;
  final VoidCallback onReleaseSlot;
  final BuildContext context;
  final bool isTakingSlot;
  final bool isOptimisticallyReleased;
  final bool isFirst;
  final bool isLast;
  final String date;

  const SlotWidget({
    super.key,
    required this.userEmail,
    required this.slot,
    required this.token,
    required this.roomId,
    required this.onTakeSlot,
    required this.isOptimisticallyReleased,
    required this.isTakingSlot,
    required this.onReleaseSlot,
    required this.context,
    required this.isFirst,
    required this.isLast,
    required this.date,
  });

  Future<void> _showNoteDialog(
    BuildContext context,
    String startTime,
    int duration,
    String date,
  ) async {
    final controller = TextEditingController();
    bool isSubmitting = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return _NoteBottomSheet(
              controller: controller,
              startTime: startTime,
              duration: duration,
              date: date,
              isSubmitting: isSubmitting,
              onSubmit: () async {
                setState(() => isSubmitting = true);
                Navigator.pop(context);
                onTakeSlot(controller.text.trim());
              },
              onCancel: () => Navigator.pop(context),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool treatAsFree = isOptimisticallyReleased;
    return Column(
      children: [
        //free slot
        if (slot.takenBy == null || treatAsFree)
          GestureDetector(
            child: Container(
              padding: EdgeInsets.fromLTRB(0, 12, 12, 12),
              width: MediaQuery.of(context).size.width * 0.95,
              decoration: BoxDecoration(
                borderRadius: isLast
                    ? BorderRadius.only(
                        topLeft: Radius.circular(0.0),
                        topRight: Radius.circular(0.0),
                        bottomLeft: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0),
                      )
                    : BorderRadius.circular(0),
                color: constants.background,
                border: Border.all(color: constants.grey, width: 0.2),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 56,
                        child: Text(
                          '${slot.startTime.split(":")[0]}${":"}${slot.startTime.split(":")[1]}',
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: constants.darkGrey,
                            fontSize: constants.fsLabel,
                            fontWeight: constants.fwRegular,
                          ),
                        ),
                      ),
                      isTakingSlot
                          ? SpinKitPouringHourGlass(
                              color: constants.primary,
                              size: constants.fsLabel,
                            )
                          : SvgPicture.asset('assets/resources/take_slot.svg'),
                    ],
                  ),
                ],
              ),
            ),

            onTap: isTakingSlot
                ? null
                : () => _showNoteDialog(
                    context,
                    slot.startTime,
                    slot.duration,
                    date,
                  ),
          ),
        if (slot.takenBy != null && !treatAsFree)
          //my slot
          slot.takenBy == userEmail
              ? Container(
                  padding: EdgeInsets.fromLTRB(0, 12, 12, 12),
                  width: MediaQuery.of(context).size.width * 0.95,
                  decoration: BoxDecoration(
                    borderRadius: isLast
                        ? BorderRadius.only(
                            topLeft: Radius.circular(0.0),
                            topRight: Radius.circular(0.0),
                            bottomLeft: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                          )
                        : BorderRadius.circular(0),
                    color: constants.primary,
                    border: Border.all(color: constants.grey, width: 0.2),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 56,

                                child: Text(
                                  '${slot.startTime.split(":")[0]}${":"}${slot.startTime.split(":")[1]}',
                                  textAlign: TextAlign.right,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: constants.background,
                                    fontSize: constants.fsLabel,
                                    fontWeight: constants.fwRegular,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                flex: 2,
                                fit: FlexFit.loose,
                                child: Text(
                                  helpers.cropText(slot.takenByName ?? ''),
                                  textAlign: TextAlign.right,
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
                                if (slot.isOnline == 1)
                                  SvgPicture.asset(
                                    'assets/resources/screen.svg',
                                    colorFilter: ColorFilter.mode(
                                      constants.background,
                                      BlendMode.srcIn,
                                    ),
                                  ),

                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () async {
                                    onReleaseSlot();
                                  },
                                  child: isOptimisticallyReleased
                                      ? SpinKitPouringHourGlass(
                                          color: constants.background,
                                          size: constants.fsLabel,
                                        )
                                      : SvgPicture.asset(
                                          'assets/resources/cross.svg',
                                          colorFilter: ColorFilter.mode(
                                            constants.background,

                                            BlendMode.srcIn,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              //someone's slot
              : Container(
                  padding: EdgeInsets.fromLTRB(0, 12, 12, 12),
                  width: MediaQuery.of(context).size.width * 0.95,
                  decoration: BoxDecoration(
                    borderRadius: isLast
                        ? BorderRadius.only(
                            topLeft: Radius.circular(0.0),
                            topRight: Radius.circular(0.0),
                            bottomLeft: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                          )
                        : BorderRadius.circular(0),
                    color: constants.red,
                    border: Border.all(color: constants.grey, width: 0.2),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 56,

                                child: Text(
                                  '${slot.startTime.split(":")[0]}${":"}${slot.startTime.split(":")[1]}',
                                  textAlign: TextAlign.right,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: constants.textUnavailableGrey,
                                    fontSize: constants.fsLabel,
                                    fontWeight: constants.fwRegular,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                flex: 2,
                                fit: FlexFit.loose,
                                child: Text(
                                  helpers.cropText(slot.takenByName ?? ''),
                                  textAlign: TextAlign.right,
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
                                if (slot.isOnline == 1)
                                  SvgPicture.asset(
                                    'assets/resources/screen.svg',
                                    colorFilter: ColorFilter.mode(
                                      constants.textUnavailableGrey,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
      ],
    );
  }
}

class _NoteBottomSheet extends StatelessWidget {
  final TextEditingController controller;
  final String startTime;
  final int duration;
  final String date;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;
  final bool isSubmitting;

  const _NoteBottomSheet({
    required this.controller,
    required this.startTime,
    required this.duration,
    required this.date,
    required this.onSubmit,
    required this.onCancel,
    required this.isSubmitting,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: constants.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Add a visit purpose",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _InfoCard(startTime: startTime, duration: duration, date: date),
            const SizedBox(height: 12),
            _NoteTextField(controller: controller),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onCancel,
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: constants.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: constants.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Submit",
                      style: TextStyle(color: constants.background),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Helper widgets (extracted for const-correctness)
class _InfoCard extends StatelessWidget {
  final String startTime;
  final int duration;
  final String date;
  const _InfoCard({
    required this.startTime,
    required this.duration,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: constants.squircleShadow(
        color: constants.background,
        borderRadius: SmoothBorderRadius(
          cornerRadius: 20,
          cornerSmoothing: 0.6,
        ),
      ),
      child: Column(
        children: [
          _InfoRow(icon: Icons.calendar_month, label: "Date", value: date),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.access_time_outlined,
            label: "Time",
            value: startTime,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.hourglass_bottom_rounded,
            label: "Duration",
            value: duration.toString(),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: constants.fsLabel, color: constants.darkGrey),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: constants.fsLabel,
                color: constants.darkGrey,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: constants.fsLabel,
            color: constants.darkGrey,
          ),
        ),
      ],
    );
  }
}

class _NoteTextField extends StatelessWidget {
  final TextEditingController controller;
  const _NoteTextField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: constants.squircleShadow(
        color: constants.background,
        borderRadius: SmoothBorderRadius(
          cornerRadius: 12,
          cornerSmoothing: 0.6,
        ),
      ),
      child: TextField(
        controller: controller,
        autofocus: true,
        maxLines: 1,
        decoration: InputDecoration(
          hintText: "Type in visit purpose...",
          filled: true,
          fillColor: constants.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
