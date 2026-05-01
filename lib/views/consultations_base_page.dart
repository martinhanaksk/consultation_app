import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/viewmodels/base_consultations_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/slot_widget.dart';
import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class BaseConsultationsPage extends StatefulWidget {
  final Widget? toggle;
  final Widget? addButton;
  final Widget? deleteButton;
  final BaseConsultationsViewmodel? viewModel;
  final Widget Function(int blockId)? editBlockButton;
  final Widget? Function(int slotId, int blockId, Color color)?
  showHistoryOption;
  final Widget? Function(int blockId, bool isEmpty)? addSlotBefore;
  final Widget? Function(int blockId, bool isEmpty)? addSlotAfter;

  const BaseConsultationsPage({
    super.key,
    this.viewModel,
    this.toggle,
    this.addButton,
    this.deleteButton,
    this.editBlockButton,
    this.showHistoryOption,
    this.addSlotBefore,
    this.addSlotAfter,
  });

  @override
  State<BaseConsultationsPage> createState() => _BaseConsultationsPageState();
}

class _BaseConsultationsPageState extends State<BaseConsultationsPage> {
  late final BaseConsultationsViewmodel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? BaseConsultationsViewmodel();
    if (widget.viewModel == null) {
      initialize();
    }
  }

  void initialize() async {
    await _viewModel.init();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBarMenu(
          viewModel: _viewModel,
          toggle: widget.toggle,
          onHomePage: true,
        ),
        drawer: SliderMenu(),
        backgroundColor: constants.background,
        body: Consumer<BaseConsultationsViewmodel>(
          builder: (context, viewModel, child) {
            return SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: RefreshIndicator(
                    color: constants.primary,
                    onRefresh: () => viewModel.loadRoom(),
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        overscroll: false,
                      ),
                      child: ListView(
                        children: [
                          const SizedBox(height: 100),
                          StickyHeader(
                            header: _RoomSelectorButton(viewModel: viewModel),
                            content: viewModel.isLoading
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 200,
                                    ),
                                    child: Center(
                                      child: SpinKitPouringHourGlass(
                                        color: constants.primary,
                                        size: constants.fsHeadline,
                                      ),
                                    ),
                                  )
                                : _ConsultationsContent(
                                    viewModel: viewModel,
                                    toggle: widget.toggle,
                                    addButton: widget.addButton,
                                    showHistoryOption: widget.showHistoryOption,
                                    deleteButton: widget.deleteButton,
                                    editBlockButton: widget.editBlockButton,
                                    addSlotBefore: widget.addSlotBefore,
                                    addSlotAfter: widget.addSlotAfter,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NoRoomsFound extends StatelessWidget {
  final BaseConsultationsViewmodel viewModel;
  const _NoRoomsFound({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 80),
              viewModel.ownerView == 0
                  ? GestureDetector(
                      onTap: () => nav.toJoinRoom(),
                      child: Text(
                        "Try joining room to get started.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: constants.fsTitle,
                          color: constants.primary,
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: () => nav.toCreateRoom(),
                      child: Text(
                        "Try creating room to get started.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: constants.fsTitle,
                          color: constants.primary,
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoomSelectorButton extends StatelessWidget {
  final BaseConsultationsViewmodel viewModel;

  const _RoomSelectorButton({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -1),
      child: Container(
        decoration: BoxDecoration(color: constants.background),
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Center(
          child: PopupMenuButton<String>(
            position: PopupMenuPosition.under,
            offset: const Offset(0, 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: constants.background,
            elevation: 12,
            shadowColor: constants.darkGrey30,
            onSelected: (String newValue) async {
              final success = await viewModel.validateAndSelectRoom(newValue);
              if (success) await viewModel.switchRoom(newValue);
            },
            itemBuilder: (context) => viewModel.rooms == null
                ? []
                : viewModel.rooms!.map((RoomModel value) {
                    final isSelected =
                        value.id.toString() == viewModel.safeSelectedRoomId;
                    return PopupMenuItem<String>(
                      value: value.id.toString(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      child: Text(
                        value.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected
                              ? constants.fwSemiBold
                              : constants.fwRegular,
                          color: isSelected
                              ? constants.primary
                              : constants.darkGrey,
                        ),
                      ),
                    );
                  }).toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: constants.squircleShadow(color: constants.grey),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    viewModel.isLoading
                        ? "Loading..."
                        : (viewModel.noRoomsFound ||
                              viewModel.selectedRoomId == null)
                        ? "No rooms created"
                        : viewModel.selectedRoom!.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: constants.fwSemiBold,
                      color:
                          (viewModel.noRoomsFound ||
                              viewModel.selectedRoomId == null)
                          ? constants.darkGrey100
                          : viewModel.isLoading
                          ? constants.primary
                          : constants.darkGrey,
                    ),
                  ),
                  const SizedBox(width: 6),
                  svgs.icon(
                    'arrow_down',
                    (viewModel.noRoomsFound || viewModel.selectedRoomId == null)
                        ? constants.darkGrey100
                        : viewModel.isLoading
                        ? constants.primary
                        : constants.darkGrey,
                    width: constants.fsBody,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConsultationsContent extends StatelessWidget {
  final BaseConsultationsViewmodel viewModel;
  final Widget? toggle;
  final Widget? addButton;
  final Widget? deleteButton;
  final Widget? Function(int slotId, int blockId, Color color)?
  showHistoryOption;
  final Widget? Function(int blockId, bool isEmpty)? addSlotBefore;
  final Widget? Function(int blockId, bool isEmpty)? addSlotAfter;
  final Widget Function(int blockId)? editBlockButton;

  const _ConsultationsContent({
    required this.viewModel,
    this.toggle,
    this.addButton,
    this.deleteButton,
    this.showHistoryOption,
    this.editBlockButton,
    this.addSlotBefore,
    this.addSlotAfter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),

        (viewModel.noRoomsFound || viewModel.selectedRoomId == null)
            ? _NoRoomsFound(viewModel: viewModel)
            : Column(
                children: [
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
                    const SizedBox(height: 20),
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
                          (block) => _ConsultationBlockCard(
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

class _ConsultationBlockCard extends StatelessWidget {
  final BaseConsultationsViewmodel viewModel;
  final MapEntry<int, List?> blockEntry;
  final Widget Function(int blockId)? editBlockButton;
  final Widget? Function(int slotId, int blockId, Color color)?
  showHistoryOption;
  final Widget? Function(int blockId, bool isEmpty)? addSlotBefore;
  final Widget? Function(int blockId, bool isEmpty)? addSlotAfter;

  const _ConsultationBlockCard({
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

                                    if (viewModel.subscribedBlocks.contains(
                                      blockEntry.key,
                                    )) {
                                      notify.showToast(
                                        "Notifications disabled for selected slot",
                                      );
                                    } else {
                                      notify.showToast(
                                        "Notifications enabled for selected slot",
                                      );
                                    }
                                  },
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
                if (addSlotBefore != null)
                  addSlotBefore!(blockEntry.key, slots.isEmpty)!,

                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: slots.length,
                  itemBuilder: (context, index) {
                    final slot = slots[index];
                    return Selector<BaseConsultationsViewmodel, (bool, bool)>(
                      selector: (context, vm) => (
                        vm.isTakingSlot(slot.id),
                        vm.isOptimisticallyReleased(slot.id),
                      ),
                      builder: (context, slotState, _) {
                        return RepaintBoundary(
                          child: SlotWidget(
                            visitReason: viewModel.visitReason,
                            showHistoryOption: showHistoryOption,
                            slot: slot,
                            roomId: viewModel.selectedRoomId!,
                            cancellationNoticeHours:
                                viewModel.selectedRoom == null
                                ? 0
                                : viewModel
                                      .selectedRoom!
                                      .cancellationNoticeHours,
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
                            date: viewModel
                                .blockDate(blockEntry.key)
                                .substring(0, 10),
                          ),
                        );
                      },
                    );
                  },
                ),
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
