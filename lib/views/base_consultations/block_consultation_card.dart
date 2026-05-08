// consultation_block_card.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Card representing a single consultation block (group of slots).
// Renders the block header with a date label, a notification bell or owner
// edit button, optional slot-insertion controls, and the slot list.

import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/base_consultations_viewmodel.dart';
import 'package:consultation_app/views/slots/slot_widget.dart';
import 'package:provider/provider.dart';

class ConsultationBlockCard extends StatelessWidget {
  final BaseConsultationsViewModel viewModel;
  // blockEntry.key = block ID, blockEntry.value = list of slots in this block
  final MapEntry<int, List?> blockEntry;
  // Null in student view — presence of this callback switches the header action
  final Widget Function(int blockId)? editBlockButton;
  final Widget? Function(int slotId, int blockId, Color color)?
  showHistoryOption;
  final Widget? Function(int blockId, bool isEmpty)? addSlotBefore;
  final Widget? Function(int blockId, bool isEmpty)? addSlotAfter;
  const ConsultationBlockCard({
    super.key,
    required this.viewModel,
    required this.blockEntry,
    this.editBlockButton,
    this.showHistoryOption,
    this.addSlotBefore,
    this.addSlotAfter,
  });
  @override
  Widget build(BuildContext context) {
    final slots = blockEntry.value!;
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            clipBehavior: Clip.hardEdge,
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: constants.squircleShadow(
              hasBorder: true,
              color: constants.background,
            ),
            child: Column(
              children: [
                // ── Block header: centered date label + trailing action ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        viewModel.blockDateLabel(blockEntry.key),
                        style: TextStyle(
                          color: constants.darkGrey,
                          fontSize: constants.fsLabel,
                          fontWeight: constants.fwSemiBold,
                        ),
                      ),
                      // Student view: bell icon toggles email notifications for the block.
                      // Owner view: replaced by the injected editBlockButton.
                      editBlockButton == null
                          ? Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                width: 20,
                                child: GestureDetector(
                                  onTap: () async {
                                    viewModel.handleEmailSubscribe(
                                      blockEntry.key,
                                    );
                                    notify.showToast(
                                      viewModel.subscribedBlocks.contains(
                                            blockEntry.key,
                                          )
                                          ? "Notifications enabled for selected slot"
                                          : "Notifications disabled for selected slot",
                                    );
                                  },
                                  // Icon reflects current subscription state
                                  child:
                                      viewModel.subscribedBlocks.contains(
                                        blockEntry.key,
                                      )
                                      ? svgs.icon(
                                          "notifications_bell_full",
                                          constants.darkGrey,
                                        )
                                      : svgs.icon(
                                          "notifications_bell_empty",
                                          constants.darkGrey,
                                        ),
                                ),
                              ),
                            )
                          : Align(
                              alignment: Alignment.centerRight,
                              child: editBlockButton!(blockEntry.key),
                            ),
                    ],
                  ),
                ),
                // Owner-only: button to insert a slot at the top of the block
                if (addSlotBefore != null)
                  addSlotBefore!(blockEntry.key, slots.isEmpty)!,
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: slots.length,
                  itemBuilder: (context, index) {
                    final slot = slots[index];
                    // Selector rebuilds only this slot when its taking/release state changes,
                    // avoiding a full-list rebuild on every interaction
                    return Selector<BaseConsultationsViewModel, (bool, bool)>(
                      selector: (context, vm) => (
                        vm.isTakingSlot(slot.id),
                        vm.isOptimisticallyReleased(slot.id),
                      ),
                      builder: (context, slotState, _) {
                        // RepaintBoundary isolates each slot's repaint from its neighbours
                        return RepaintBoundary(
                          child: SlotWidget(
                            visitReason: viewModel.visitReason,
                            showHistoryOption: showHistoryOption,
                            slot: slot,
                            cancellationNoticeHours:
                                viewModel
                                    .selectedRoom
                                    ?.cancellationNoticeHours ??
                                0,
                            blockId: blockEntry.key,
                            isOwnerView: viewModel.ownerView,
                            onChangeConsultationType: () =>
                                viewModel.onChangeConsultationType(slot.id),
                            onTakeSlot: (note, isOnline) =>
                                viewModel.takeSlot(slot.id, note, isOnline),
                            onReleaseSlot: () => viewModel.releaseSlot(slot.id),
                            context: context,
                            isTakingSlot: slotState.$1,
                            isOptimisticallyReleased: slotState.$2,
                            isFirst: index == 0,
                            isLast: index == slots.length - 1,
                            // Pass only the date portion
                            date: viewModel
                                .blockDate(blockEntry.key)
                                .substring(0, 10),
                          ),
                        );
                      },
                    );
                  },
                ),
                // Owner-only: button to append a slot at the bottom of the block
                if (addSlotAfter != null)
                  addSlotAfter!(blockEntry.key, slots.isEmpty)!,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
