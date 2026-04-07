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
  final String token;
  final String email;
  final Widget? toggle;
  final Widget? addButton;
  final Widget? deleteButton;
  final BaseConsultationsViewmodel? viewModel;
  final Widget Function(int blockId)? editBlockButton;
  final Widget? Function(int blockId, bool isEmpty)? addSlotBefore;
  final Widget? Function(int blockId, bool isEmpty)? addSlotAfter;

  const BaseConsultationsPage({
    super.key,
    required this.token,
    required this.email,
    this.viewModel,
    this.toggle,
    this.addButton,
    this.deleteButton,
    this.editBlockButton,
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
    await _viewModel.init(widget.token, widget.email);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBarMenu(
          viewModel: _viewModel,
          toggle: widget.toggle,
          token: widget.token,
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
                    onRefresh: () => viewModel.loadRoom(widget.token),
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
                                    token: widget.token,
                                    email: widget.email,
                                    toggle: widget.toggle,
                                    addButton: widget.addButton,
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

// ---------------------------------------------------------------------------

class _NoRoomsFound extends StatelessWidget {
  final String token;
  final BaseConsultationsViewmodel viewModel;
  const _NoRoomsFound({required this.token, required this.viewModel});

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
                      onTap: () => nav.toJoinRoom(token: token),
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

// ---------------------------------------------------------------------------

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
            shadowColor: constants.darkGrey.withValues(alpha: 0.12),
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
                    viewModel.rooms
                            ?.cast<RoomModel?>()
                            .firstWhere(
                              (r) =>
                                  r!.id.toString() ==
                                  viewModel.safeSelectedRoomId,
                              orElse: () => null,
                            )
                            ?.title ??
                        "Select a Room",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: constants.fwSemiBold,

                      color:
                          (viewModel.noRoomsFound ||
                              viewModel.selectedRoomId == null)
                          ? constants.darkGrey.withAlpha(50)
                          : constants.darkGrey,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color:
                        (viewModel.noRoomsFound ||
                            viewModel.selectedRoomId == null)
                        ? constants.darkGrey.withAlpha(50)
                        : constants.darkGrey,
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

// ---------------------------------------------------------------------------

class _ConsultationsContent extends StatelessWidget {
  final BaseConsultationsViewmodel viewModel;
  final String token;
  final String email;
  final Widget? toggle;
  final Widget? addButton;
  final Widget? deleteButton;
  final Widget? Function(int blockId, bool isEmpty)? addSlotBefore;
  final Widget? Function(int blockId, bool isEmpty)? addSlotAfter;
  final Widget Function(int blockId)? editBlockButton;

  const _ConsultationsContent({
    required this.viewModel,
    required this.token,
    required this.email,
    this.toggle,
    this.addButton,
    this.deleteButton,
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
            ? _NoRoomsFound(token: token, viewModel: viewModel)
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
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text(
                          "No upcoming consultations found.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
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
                        const SizedBox(height: 30),
                        ..._sortedBlocks().map(
                          (block) => _ConsultationBlockCard(
                            viewModel: viewModel,
                            blockEntry: block,
                            token: token,
                            email: email,
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

// ---------------------------------------------------------------------------

class _ConsultationBlockCard extends StatelessWidget {
  final BaseConsultationsViewmodel viewModel;
  final MapEntry<int, List?> blockEntry;
  final String token;
  final String email;
  final Widget Function(int blockId)? editBlockButton;
  final Widget? Function(int blockId, bool isEmpty)? addSlotBefore;
  final Widget? Function(int blockId, bool isEmpty)? addSlotAfter;

  const _ConsultationBlockCard({
    required this.viewModel,
    required this.blockEntry,
    required this.token,
    required this.email,
    this.editBlockButton,
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
              border: Border.all(color: constants.grey, width: 0.2),
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
                                    bool canRecieveEmails =
                                        await prefs.getItem('receiveEmails') ==
                                        true;
                                    if (!canRecieveEmails) {
                                      notify.showToast(
                                        "Turn on email recieving in the settings",
                                      );
                                      return;
                                    }
                                    // TODO viewModel.setTemporarybellboolean(
                                    //   !viewModel.temporaryBellBoolean,
                                    // );
                                    viewModel.handleEmailSubscribe(
                                      token,
                                      blockEntry.key,
                                    );

                                    if (true) {
                                      //viewModel.temporaryBellBoolean TODO
                                      notify.showToast(
                                        "Notifications enabled for selected slot",
                                      );
                                    } else {
                                      notify.showToast(
                                        "Notifications disabled for selected slot",
                                      );
                                    }
                                  },
                                  child:
                                      true //viewModel.temporaryBellBoolean TODO
                                      ? SvgPicture.asset(
                                          'assets/resources/notifications_bell_full.svg',
                                          colorFilter: ColorFilter.mode(
                                            constants.darkGrey,
                                            BlendMode.srcIn,
                                          ),
                                        )
                                      : SvgPicture.asset(
                                          'assets/resources/notifications_bell_empty.svg',
                                          colorFilter: ColorFilter.mode(
                                            constants.darkGrey,
                                            BlendMode.srcIn,
                                          ),
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
                    return Consumer<BaseConsultationsViewmodel>(
                      builder: (context, vm, _) {
                        return RepaintBoundary(
                          child: SlotWidget(
                            userEmail: email,
                            slot: slots[index],
                            token: token,
                            roomId: vm.selectedRoomId!,
                            onTakeSlot: (note) =>
                                vm.takeSlot(token, slot.id, note),
                            onReleaseSlot: () => vm.releaseSlot(token, slot.id),
                            context: context,
                            isTakingSlot: vm.isTakingSlot(slot.id),
                            isOptimisticallyReleased: vm
                                .isOptimisticallyReleased(slot.id),
                            isFirst: index == 0,
                            isLast: index == slots.length - 1,
                            date: vm.blockDateLabel(blockEntry.key),
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
