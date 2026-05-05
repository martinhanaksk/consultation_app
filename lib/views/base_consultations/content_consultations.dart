// consultations_content.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Scrollable body of the consultations page. Handles three states:
// no room selected/found, room loaded with blocks, and room loaded but empty.
// Owner-specific action widgets (add, delete, edit) are injected by the caller.

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/base_consultations_viewmodel.dart';
import 'no_rooms_found.dart';
import 'block_consultation_card.dart';

class ConsultationsContent extends StatelessWidget {
  final BaseConsultationsViewmodel viewModel;
  final Widget? toggle;
  final Widget? addButton;
  final String? shortName;
  final Widget? deleteButton;
  final Widget? Function(int slotId, int blockId, Color color)?
  showHistoryOption;
  final Widget? Function(int blockId, bool isEmpty)? addSlotBefore;
  final Widget? Function(int blockId, bool isEmpty)? addSlotAfter;
  final Widget Function(int blockId)? editBlockButton;
  const ConsultationsContent({
    super.key,
    required this.viewModel,
    this.toggle,
    this.shortName,
    this.addButton,
    this.deleteButton,
    this.showHistoryOption,
    this.editBlockButton,
    this.addSlotBefore,
    this.addSlotAfter,
  });
  @override
  Widget build(BuildContext context) {
    // Treat a missing room selection the same as no rooms existing
    final bool noRoom =
        viewModel.noRoomsFound || viewModel.selectedRoomId == null;
    return Column(
      children: [
        const SizedBox(height: 12),
        noRoom
            ? NoRoomsFound(viewModel: viewModel)
            : Column(
                children: [
                  // Show a spinner while the room's public website URL is being resolved
                  viewModel.isWebsiteLoading
                      ? Center(
                          child: SpinKitPouringHourGlass(
                            color: constants.primary,
                            size: constants.fsHeadline,
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () =>
                              viewModel.launchWebsite(shortName ?? ""),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: constants.primary,
                            disabledBackgroundColor: constants.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 2,
                            shadowColor: constants.primary,
                          ),
                          child: Text(
                            "Room Link",
                            style: TextStyle(
                              color: constants.background,
                              fontSize: constants.fsLabel,
                            ),
                          ),
                        ),
                  const SizedBox(height: 12),
                  // Owner-only action row; hidden entirely when neither button is provided
                  if (addButton != null || deleteButton != null) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (addButton != null) addButton!,
                        // Separator only rendered when both buttons are present
                        if (addButton != null && deleteButton != null)
                          const SizedBox(width: 16),
                        if (deleteButton != null) deleteButton!,
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (viewModel.getBlocksCount() == 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Center(
                        child: Text(
                          "No upcoming consultations found.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: constants.darkGrey,
                            fontWeight: constants.fwSemiBold,
                            fontSize: constants.fsTitle,
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        // Blocks are sorted chronologically before rendering
                        ..._sortedBlocks().map(
                          (block) => ConsultationBlockCard(
                            viewModel: viewModel,
                            blockEntry: block,
                            showHistoryOption: showHistoryOption,
                            editBlockButton: editBlockButton,
                            addSlotBefore: addSlotBefore,
                            addSlotAfter: addSlotAfter,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
      ],
    );
  }

  // Sorts blocks by their date ascending so the nearest upcoming block appears first.
  List<MapEntry<int, List?>> _sortedBlocks() {
    final sorted = viewModel.slotsInBlocks.entries.toList();
    final blockMap = {for (var b in viewModel.blocks) b.id: b};
    sorted.sort(
      (a, b) => blockMap[a.key]!.date.compareTo(blockMap[b.key]!.date),
    );
    return sorted;
  }
}
