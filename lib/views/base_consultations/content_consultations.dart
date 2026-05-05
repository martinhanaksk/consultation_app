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
  final Widget? Function(int slotId, int blockId, Color color)? showHistoryOption;
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
    final bool noRoom =
        viewModel.noRoomsFound || viewModel.selectedRoomId == null;

    return Column(
      children: [
        const SizedBox(height: 12),
        noRoom
            ? NoRoomsFound(viewModel: viewModel)
            : Column(
                children: [
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
                  if (addButton != null || deleteButton != null) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (addButton != null) addButton!,
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

  List<MapEntry<int, List?>> _sortedBlocks() {
    final sorted = viewModel.slotsInBlocks.entries.toList();
    final blockMap = {for (var b in viewModel.blocks) b.id: b};
    sorted.sort(
      (a, b) => blockMap[a.key]!.date.compareTo(blockMap[b.key]!.date),
    );
    return sorted;
  }
}
