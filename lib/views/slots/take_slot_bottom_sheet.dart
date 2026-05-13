// take_slot_bottom_sheet.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Bottom sheet shown when a student taps a free slot.
// Displays slot info (date, time, duration), a pre-filled visit reason field,
// a consultation type toggle, and Confirm/Cancel actions.

import 'package:consultation_app/views/custom_widgets/custom_text_field_widget.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';
import 'keyboard_padding.dart';
import 'type_toggle.dart';

class TakeSlotBottomSheet extends StatefulWidget {
  final String visitReason;
  final String startTime;
  // Slot-level online flag set by the teacher when creating the block
  final bool isOnline;
  // Teacher's own preference for attending online
  final bool isOnlineTeacher;
  final int duration;
  final String date;
  final void Function(String note, int isOnline) onTakeSlot;
  final VoidCallback onCancel;
  final bool isTeacher;
  const TakeSlotBottomSheet({
    super.key,
    required this.visitReason,
    required this.startTime,
    required this.isOnline,
    required this.isOnlineTeacher,
    required this.duration,
    required this.date,
    required this.onTakeSlot,
    required this.onCancel,
    required this.isTeacher,
  });

  @override
  State<TakeSlotBottomSheet> createState() => _TakeSlotBottomSheetState();
}

class _TakeSlotBottomSheetState extends State<TakeSlotBottomSheet> {
  late final TextEditingController _controller;
  bool _isOnlineSelected = false;
  bool _isOnlineTeacherSelected = false;
  // Guards the confirm button against double-tap. Sheet is popped immediately after submit
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.visitReason);
    _isOnlineSelected = widget.isOnline;
    _isOnlineTeacherSelected = widget.isOnlineTeacher;
    // Places the cursor at the end of the pre-filled visit reason so the user
    // can append text without repositioning manually
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
    return KeyboardPadding(
      child: Container(
        decoration: BoxDecoration(
          color: constants.background,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
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
            SlotInfoCard(
              startTime: widget.startTime,
              duration: widget.duration,
              // Converts (2025-01-15 → 2025.01.15)
              date: widget.date.replaceAll("-", "."),
            ),
            const SizedBox(height: 12),
            CustomInputTextField(
              controller: _controller,
              hintText: "Type in visit reason...",
              filled: true,
            ),
            const SizedBox(height: 16),
            ConsultationTypeToggle(
              isOnlineSelected: _isOnlineSelected,
              isOnlineTeacherSelected: _isOnlineTeacherSelected,
              name: "",
              reason: "",
              onChanged: (bool newValue) =>
                  setState(() => _isOnlineSelected = newValue),
              isTeacher: widget.isTeacher,
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
                            // Converts the bool toggle back to the API's int convention
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

// Summary card displayed at the top of TakeSlotBottomSheet showing
// the slot's date, start time, and duration before the user confirms.
class SlotInfoCard extends StatelessWidget {
  final String startTime;
  final int duration;
  final String date;

  // Shared border radius for consistent squircle styling across the card
  static final _borderRadius = SmoothBorderRadius(
    cornerRadius: 20,
    cornerSmoothing: 0.6,
  );

  const SlotInfoCard({
    super.key,
    required this.startTime,
    required this.duration,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final parts = startTime.split(":");
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
          _InfoRow(
            name: 'clock',
            label: "Start time",
            value: '${parts[0]}:${parts[1]}',
          ),
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

// Single icon + label + value row used inside SlotInfoCard
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
