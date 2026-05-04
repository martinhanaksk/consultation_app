import 'package:consultation_app/views/custom_widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:consultation_app/models/slot_model.dart';
import 'package:consultation_app/setup.dart';
import 'package:figma_squircle/figma_squircle.dart';

class SlotWidget extends StatelessWidget {
  final String visitReason;
  final SlotModel slot;
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
      builder: (context) {
        return _NoteBottomSheet(
          visitReason: visitReason,
          startTime: startTime,
          isOnline: slot.isOnline == 0 ? false : true,
          isOnlineTeacher: slot.isOnlineTeacher == 0 ? false : true,
          duration: duration,
          date: date,
          onTakeSlot: onTakeSlot,
          onCancel: () => Navigator.pop(context),
        );
      },
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
      builder: (context) {
        return _ConsultationTypeSelection(
          isOnline: isOnline,
          isOnlineTeacher: isOnlineTeacher,
          name: name,
          onChangeConsultationType: onChangeConsultationType,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool treatAsFree = isOptimisticallyReleased;
    final bool isFree = slot.takenBy == null || treatAsFree;
    final bool isMySlot = !isFree && slot.takenBy == sm.email;
    final bool isSomeonesSlot = !isFree && !isMySlot;
    final bool canSeeIdentity = sm.visibility == true;

    if (isFree) {
      return _FreeSlot(
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
      return _CurrentUserSlot(
        slot: slot,
        date: date,
        cancellationNoticeHours: cancellationNoticeHours,
        showHistoryOption: showHistoryOption,
        blockId: blockId,
        isOptimisticallyReleased: isOptimisticallyReleased,
        onRelease: onReleaseSlot,
        onTap: () => _showChangeConsultationTypeDialog(
          context,
          canSeeIdentity ? (slot.takenByName ?? "") : "",
          slot.isOnline,
          slot.isOnlineTeacher,
        ),
      );
    }

    if (isSomeonesSlot) {
      return _AnotherUsersSlot(
        slot: slot,
        showHistoryOption: showHistoryOption,
        blockId: blockId,
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

    return const SizedBox.shrink();
  }
}

class _FreeSlot extends StatelessWidget {
  final SlotModel slot;
  final String date;
  final bool isTakingSlot;
  final int blockId;
  final Widget? Function(int slotId, int blockId, Color color)?
  showHistoryOption;
  final VoidCallback onTap;

  const _FreeSlot({
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
            _SlotTime(time: slot.startTime, color: constants.darkGrey),
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
                    svgs.icon(
                      'screen',
                      constants.darkGrey,
                      width: constants.fsTitle,
                    ),
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

class _CurrentUserSlot extends StatelessWidget {
  final SlotModel slot;
  final String date;
  final int cancellationNoticeHours;
  final int blockId;
  final bool isOptimisticallyReleased;
  final Widget? Function(int slotId, int blockId, Color color)?
  showHistoryOption;
  final VoidCallback onRelease;
  final VoidCallback onTap;

  const _CurrentUserSlot({
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
    onRelease();

    final DateTime slotStart = DateTime.parse('$date ${slot.startTime}');
    final Duration timeDifference = slotStart.difference(DateTime.now());

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
                _SlotTime(time: slot.startTime, color: constants.background),
                const SizedBox(width: 12),
                Flexible(
                  flex: 2,
                  fit: FlexFit.loose,
                  child: Text(
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
                    showHistoryOption!(
                          slot.id,
                          blockId,
                          constants.background,
                        ) ??
                        const SizedBox.shrink(),
                  if (slot.isOnline == 1) ...[
                    const SizedBox(width: 8),
                    svgs.icon(
                      'screen',
                      constants.background,
                      width: constants.fsTitle,
                    ),
                  ],
                  const SizedBox(width: 8),
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

class _AnotherUsersSlot extends StatelessWidget {
  final SlotModel slot;
  final int blockId;
  final Widget? Function(int slotId, int blockId, Color color)?
  showHistoryOption;
  final VoidCallback? onTap;

  const _AnotherUsersSlot({
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
                _SlotTime(
                  time: slot.startTime,
                  color: constants.textUnavailableGrey,
                ),
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
                    showHistoryOption!(
                          slot.id,
                          blockId,
                          constants.background,
                        ) ??
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

class _SlotTime extends StatelessWidget {
  final String time;
  final Color color;

  const _SlotTime({required this.time, required this.color});

  @override
  Widget build(BuildContext context) {
    final parts = time.split(":");
    return SizedBox(
      width: 56,
      child: Text(
        '${parts[0]}:${parts[1]}',
        textAlign: TextAlign.right,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: constants.fsLabel,
          fontWeight: constants.fwRegular,
        ),
      ),
    );
  }
}

class _ConsultationTypeSelection extends StatefulWidget {
  final VoidCallback onChangeConsultationType;
  final int isOnline;
  final int isOnlineTeacher;
  final String name;
  const _ConsultationTypeSelection({
    required this.onChangeConsultationType,
    required this.isOnline,
    required this.isOnlineTeacher,
    required this.name,
  });

  @override
  State<_ConsultationTypeSelection> createState() =>
      _ConsultationTypeSelectionState();
}

class _ConsultationTypeSelectionState
    extends State<_ConsultationTypeSelection> {
  bool isOnlineSelected = false;
  bool isOnlineTeacherSelected = false;
  bool startingValue = false;

  @override
  void initState() {
    super.initState();
    isOnlineSelected = widget.isOnline == 1;
    isOnlineTeacherSelected = widget.isOnlineTeacher == 1;
    startingValue = isOnlineSelected;
  }

  @override
  Widget build(BuildContext context) {
    return _KeyboardPadding(
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
              isOnlineTeacherSelected: isOnlineTeacherSelected,
              name: widget.name,
              onChanged: (bool newValue) =>
                  setState(() => isOnlineSelected = newValue),
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
                      "Change",
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
  final bool isOnlineTeacherSelected;
  final String name;
  final ValueChanged<bool> onChanged;

  const _ConsultationTypeToggle({
    required this.isOnlineSelected,
    required this.isOnlineTeacherSelected,
    required this.name,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool _isOnlineSelected = sm.role == "teacher"
        ? isOnlineSelected
        : isOnlineTeacherSelected
        ? true
        : isOnlineSelected;

    return Column(
      children: [
        Text(
          "Change Consultation type",
          style: TextStyle(
            fontSize: constants.fsTitle,
            fontWeight: constants.fwSemiBold,
            color: constants.darkGrey,
          ),
        ),
        if (name.isNotEmpty) ...[
          const SizedBox(height: 20),
          RichText(
            text: TextSpan(
              text: 'Reserved by: ',
              children: [
                TextSpan(
                  text: name,
                  style: TextStyle(
                    fontSize: constants.fsBody,
                    fontWeight: constants.fwSemiBold,
                    color: constants.primary,
                  ),
                ),
              ],
              style: TextStyle(
                fontSize: constants.fsBody,
                fontWeight: constants.fwRegular,
                color: constants.darkGrey,
              ),
            ),
          ),
        ],
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => onChanged(false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isOnlineSelected
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
                      _isOnlineSelected
                          ? constants.darkGrey150
                          : constants.background,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "In-Person",
                      style: TextStyle(
                        color: _isOnlineSelected
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
                onPressed: () => onChanged(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isOnlineSelected
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
                      _isOnlineSelected
                          ? constants.background
                          : constants.darkGrey150,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Online",
                      style: TextStyle(
                        color: _isOnlineSelected
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
  final bool isOnline;
  final bool isOnlineTeacher;
  final int duration;
  final String date;
  final void Function(String note, int isOnline) onTakeSlot;
  final VoidCallback onCancel;

  const _NoteBottomSheet({
    required this.visitReason,
    required this.startTime,
    required this.isOnline,
    required this.isOnlineTeacher,
    required this.duration,
    required this.date,
    required this.onTakeSlot,
    required this.onCancel,
  });

  @override
  State<_NoteBottomSheet> createState() => __NoteBottomSheetState();
}

class __NoteBottomSheetState extends State<_NoteBottomSheet> {
  late final TextEditingController _controller;
  bool _isOnlineSelected = false;
  bool _isOnlineTeacherSelected = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.visitReason);
    _isOnlineSelected = widget.isOnline;
    _isOnlineTeacherSelected = widget.isOnlineTeacher;
    if (_controller.text.isNotEmpty) {
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _KeyboardPadding(
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
                  fontSize: constants.fsHeadline,
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
            CustomInputTextField(
              controller: _controller,
              hintText: "Type in visit reason...",
              filled: true,
            ),
            const SizedBox(height: 16),
            _ConsultationTypeToggle(
              isOnlineSelected: _isOnlineSelected,
              isOnlineTeacherSelected: _isOnlineTeacherSelected,
              name: "",
              onChanged: (bool newValue) =>
                  setState(() => _isOnlineSelected = newValue),
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
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            FocusScope.of(context).unfocus();
                            setState(() => _isSubmitting = true);
                            widget.onTakeSlot(
                              _controller.text.trim(),
                              _isOnlineSelected ? 1 : 0,
                            );
                            Navigator.pop(context);
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
                      "Take",
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

class _KeyboardPadding extends StatelessWidget {
  final Widget child;
  const _KeyboardPadding({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: child,
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String startTime;
  final int duration;
  final String date;

  static final _borderRadius = SmoothBorderRadius(
    cornerRadius: 20,
    cornerSmoothing: 0.6,
  );

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
        borderRadius: _borderRadius,
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
