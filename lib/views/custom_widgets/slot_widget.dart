import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:consultation_app/models/slot_model.dart';
import 'package:consultation_app/setup.dart';
import 'package:figma_squircle/figma_squircle.dart';

class SlotWidget extends StatelessWidget {
  final String userEmail;
  final String visitReason;
  final SlotModel slot;
  final String token;
  final String roomId;
  final int cancellationNoticeHours;
  final int blockId;
  final int isOwnerView;
  final Widget? Function(int slotId, int blockId, Color color)?
  showHistoryOption;
  final void Function(String note, int isOnline) onTakeSlot;
  final VoidCallback onReleaseSlot;
  final VoidCallback onChangeConsultationType;
  final BuildContext context;
  final bool isTakingSlot;
  final bool isOptimisticallyReleased;
  final bool isFirst;
  final bool isLast;
  final String date;

  const SlotWidget({
    super.key,
    required this.userEmail,
    required this.visitReason,
    required this.slot,
    required this.token,
    required this.roomId,
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
    bool isSubmitting = false;
    bool isOnlineSelected = false;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: constants.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return _NoteBottomSheet(
              visitReason: visitReason,
              startTime: startTime,
              duration: duration,
              date: date,
              isSubmitting: isSubmitting,
              onChanged: (bool newValue) {
                setState(() {
                  isOnlineSelected = newValue;
                });
              },
              isOnlineSelected: isOnlineSelected,
              onSubmit: (String submittedText) async {
                setState(() => isSubmitting = true);
                onTakeSlot(submittedText.trim(), isOnlineSelected ? 1 : 0);
                Navigator.pop(context);
              },
              onCancel: () => Navigator.pop(context),
            );
          },
        );
      },
    );
  }

  Future<void> _showChangeConsultationTypeDialog(
    BuildContext context,
    int isOnline,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: constants.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return _ConsultationTypeSelection(
              isOnline: isOnline,
              onChangeConsultationType: onChangeConsultationType,
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
          InkWell(
            onTap: isTakingSlot
                ? null
                : () => _showTakeSlotDialog(
                    context,
                    slot.startTime,
                    slot.duration,
                    date,
                  ),
            child: Container(
              padding: EdgeInsets.fromLTRB(0, 12, 12, 12),
              width: MediaQuery.of(context).size.width * 0.95,

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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (showHistoryOption != null)
                            showHistoryOption!(
                                  slot.id,
                                  blockId,
                                  constants.darkGrey,
                                ) ??
                                const SizedBox.shrink(),
                          if (slot.isOnline == 1)
                            svgs.icon(
                              'screen',
                              constants.darkGrey,
                              width: constants.fsTitle,
                            ),
                          SizedBox(width: 8),
                          isTakingSlot
                              ? SpinKitPouringHourGlass(
                                  color: constants.primary,
                                  size: constants.fsLabel,
                                )
                              : svgs.icon("add", constants.darkGrey),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
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
                  child: InkWell(
                    onTap: () {
                      _showChangeConsultationTypeDialog(context, slot.isOnline);
                    },
                    child: Row(
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
                              if (showHistoryOption != null)
                                showHistoryOption!(
                                      slot.id,
                                      blockId,
                                      constants.background,
                                    ) ??
                                    const SizedBox.shrink(),
                              if (slot.isOnline == 1) const SizedBox(width: 8),
                              if (slot.isOnline == 1)
                                svgs.icon(
                                  'screen',
                                  constants.background,
                                  width: constants.fsTitle,
                                ),

                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () async {
                                  onReleaseSlot();
                                  String combinedStr =
                                      '$date ${slot.startTime}';
                                  DateTime finalSlotStartTime = DateTime.parse(
                                    combinedStr,
                                  );
                                  final timeDifference = finalSlotStartTime
                                      .difference(DateTime.now());
                                  if (timeDifference.inHours <
                                      cancellationNoticeHours) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: constants.background,
                                          title: RichText(textAlign: TextAlign.center,
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
                                                    fontSize:
                                                        constants.fsHeadline,
                                                    fontWeight: constants
                                                        .fwSemiBold, // Or FontWeight.bold
                                                    color: constants
                                                        .primary, // Optional: make it your app's primary color
                                                  ),
                                                ),

                                                const TextSpan(
                                                  text:
                                                      'You are canceling this consultation very close to its start time.\n\n'
                                                      'Next time, please try to cancel at least ',
                                                ),
                                                TextSpan(
                                                  text:
                                                      cancellationNoticeHours ==
                                                          1
                                                      ? '$cancellationNoticeHours hour'
                                                      : '$cancellationNoticeHours hours',
                                                  style: TextStyle(
                                                    fontWeight: constants
                                                        .fwSemiBold, // Or FontWeight.bold
                                                    color: constants
                                                        .primary, // Optional: make it your app's primary color
                                                  ),
                                                ),
                                                const TextSpan(
                                                  text: ' in advance.',
                                                ),
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
                                },
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
                  child: InkWell(
                    onTap: () {
                      if (isOwnerView == 1) {
                        _showChangeConsultationTypeDialog(
                          context,
                          slot.isOnline,
                        );
                      }
                    },
                    child: Row(
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
                              if (showHistoryOption != null)
                                showHistoryOption!(
                                      slot.id,
                                      blockId,
                                      constants.background,
                                    ) ??
                                    const SizedBox.shrink(),
                              if (slot.isOnline == 1) const SizedBox(width: 8),
                              if (slot.isOnline == 1)
                                svgs.icon("screen", constants.background),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      ],
    );
  }
}

class _ConsultationTypeSelection extends StatefulWidget {
  final VoidCallback onChangeConsultationType;
  final int isOnline;
  const _ConsultationTypeSelection({
    required this.onChangeConsultationType,
    required this.isOnline,
  });

  @override
  State<_ConsultationTypeSelection> createState() =>
      _ConsultationTypeSelectionState();
}

class _ConsultationTypeSelectionState
    extends State<_ConsultationTypeSelection> {
  bool isOnlineSelected = false;
  bool startingValue = false;
  @override
  void initState() {
    super.initState();
    isOnlineSelected = (widget.isOnline == 1 ? true : false);
    startingValue = isOnlineSelected;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: constants.squircleShadow(
          color: constants.background,
          hasBorder: false,
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ConsultationTypeToggle(
              isOnlineSelected: isOnlineSelected,
              onChanged: (bool newValue) {
                setState(() {
                  isOnlineSelected = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: constants.background),
                      ),
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: constants.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (startingValue != isOnlineSelected) {
                        widget.onChangeConsultationType();
                      }
                      Navigator.pop(context, isOnlineSelected);
                    },
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

class _ConsultationTypeToggle extends StatelessWidget {
  final bool isOnlineSelected;
  final ValueChanged<bool> onChanged;
  const _ConsultationTypeToggle({
    required this.isOnlineSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Change Consultation type",
          style: TextStyle(
            fontSize: constants.fsLabel,
            fontWeight: constants.fwSemiBold,
          ),
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  onChanged(false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOnlineSelected
                      ? constants.background
                      : constants.darkGrey200,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: constants.background),
                  ),
                  elevation: 0,
                ),
                child: Column(
                  children: [
                    svgs.icon(
                      "location",
                      isOnlineSelected
                          ? constants.darkGrey150
                          : constants.background,
                    ),

                    const SizedBox(height: 6),
                    Text(
                      "In-Person",
                      style: TextStyle(
                        color: isOnlineSelected
                            ? constants.darkGrey150
                            : constants.background,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  onChanged(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOnlineSelected
                      ? constants.darkGrey200
                      : constants.background,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: constants.background),
                  ),
                  elevation: 0,
                ),
                child: Column(
                  children: [
                    svgs.icon(
                      "screen",
                      isOnlineSelected
                          ? constants.background
                          : constants.darkGrey150,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Online",
                      style: TextStyle(
                        color: isOnlineSelected
                            ? constants.background
                            : constants.darkGrey150,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NoteBottomSheet extends StatefulWidget {
  final String visitReason;
  final String startTime;
  final int duration;
  final bool isOnlineSelected;
  final ValueChanged<bool> onChanged;
  final String date;
  final ValueChanged<String> onSubmit;
  final VoidCallback onCancel;
  final bool isSubmitting;

  const _NoteBottomSheet({
    required this.visitReason,
    required this.startTime,
    required this.duration,
    required this.onChanged,
    required this.date,
    required this.isOnlineSelected,
    required this.onSubmit,
    required this.onCancel,
    required this.isSubmitting,
  });
  @override
  State<_NoteBottomSheet> createState() => __NoteBottomSheetState();
}

class __NoteBottomSheetState extends State<_NoteBottomSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.visitReason);

    if (_controller.text.isNotEmpty) {
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: constants.squircleShadow(
          color: constants.background,
          hasBorder: false,
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Make Reservation',
                style: TextStyle(
                  fontSize: constants.fsTitle,
                  fontWeight: constants.fwSemiBold,
                  color: constants.darkGrey,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _InfoCard(
              startTime: widget.startTime,
              duration: widget.duration,
              date: widget.date.replaceAll("-", "."),
            ),
            const SizedBox(height: 12),
            _NoteTextField(controller: _controller),
            const SizedBox(height: 16),
            _ConsultationTypeToggle(
              isOnlineSelected: widget.isOnlineSelected,
              onChanged: widget.onChanged,
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: widget.onCancel,
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: constants.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.isSubmitting
                        ? null
                        : () => widget.onSubmit(_controller.text),
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
          _InfoRow(name: 'calendar', label: "Date", value: date),
          const SizedBox(height: 12),
          _InfoRow(name: 'clock', label: "Time", value: startTime),
          const SizedBox(height: 12),
          _InfoRow(
            name: 'hourglass',
            label: "Duration",
            value: duration.toString(),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String name;
  final String label;
  final String value;
  const _InfoRow({
    required this.name,
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
            svgs.icon(name, constants.darkGrey, width: constants.fsLabel),

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
        style: TextStyle(color: constants.darkGrey),
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
