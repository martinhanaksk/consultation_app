import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/viewmodels/base_consultations_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/slot_widget.dart';
import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';
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
  const BaseConsultationsPage({
    super.key,
    required this.token,
    required this.email, this.viewModel, 
    this.toggle,
    this.addButton,
    this.deleteButton,
    this.editBlockButton,
  });

  @override
  State<BaseConsultationsPage> createState() => _BaseConsultationsPageState();
}

class _BaseConsultationsPageState extends State<BaseConsultationsPage> {
  late final BaseConsultationsViewmodel _viewModel;
  @override
  void initState() {
    super.initState();
   _viewModel = widget.viewModel ?? BaseConsultationsViewmodel(); if (widget.viewModel == null) {
      _viewModel.init(widget.token, widget.email);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<BaseConsultationsViewmodel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBarMenu(),
            drawer: SliderMenu(),
            backgroundColor: constants.background,
            body: SafeArea(
              child: viewModel.isLoading
                  ? Center(
                      child: SpinKitPouringHourGlass(
                        color: constants.primary,
                        size: constants.fsHeadline,
                      ),
                    )
                  : (viewModel.noRoomsFound || viewModel.selectedRoomId == null)
                  ? Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 600),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                            child: Column(
                              children: [
                                SizedBox(height: 80),
                                GestureDetector(
                                  child: Text(
                                    "Try joining room to get started.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: constants.fsTitle,
                                      color: constants.primary,
                                    ),
                                  ),
                                  onTap: () =>
                                      nav.toJoinRoom(token: widget.token),
                                ),
                                SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 600),
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            overscroll: false,
                          ),
                          child: ListView(
                            children: [
                              SizedBox(height: 100),
                              StickyHeader(
                                header: Transform.translate(
                                  offset: const Offset(0, -1),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          constants.background,
                                          constants.background.withValues(
                                            alpha: 0.95,
                                          ),
                                          constants.background.withValues(
                                            alpha: 0.6,
                                          ),
                                          constants.background.withValues(
                                            alpha: 0.3,
                                          ),
                                          constants.background.withValues(
                                            alpha: 0.0,
                                          ),
                                        ],
                                        stops: const [0.0, 0.7, 0.8, 0.9, 1.0],
                                      ),
                                    ),
                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 50),
                                    child: Center(
                                      child: PopupMenuButton<String>(
                                        position: PopupMenuPosition.under,
                                        offset: const Offset(0, 6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        color: constants.background,
                                        elevation: 12,
                                        shadowColor: constants.darkGrey
                                            .withValues(alpha: 0.12),
                                        onSelected: (String newValue) async {
                                          final success = await viewModel
                                              .validateAndSelectRoom(newValue);
                                          if (success) {
                                            await viewModel.switchRoom(
                                              newValue,
                                            );
                                          }
                                        },
                                        itemBuilder: (context) =>
                                            viewModel.rooms == null
                                            ? []
                                            : viewModel.rooms!.map((
                                                RoomModel value,
                                              ) {
                                                final isSelected =
                                                    value.id.toString() ==
                                                    viewModel
                                                        .safeSelectedRoomId;
                                                return PopupMenuItem<String>(
                                                  value: value.id.toString(),
                                                  padding:
                                                      const EdgeInsets.symmetric(
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
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 12,
                                          ),
                                          decoration: constants.squircleShadow(
                                            color: constants.grey,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                viewModel.rooms
                                                        ?.cast<RoomModel?>()
                                                        .firstWhere(
                                                          (r) =>
                                                              r!.id
                                                                  .toString() ==
                                                              viewModel
                                                                  .safeSelectedRoomId,
                                                          orElse: () => null,
                                                        )
                                                        ?.title ??
                                                    "Select a Room",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight:
                                                      constants.fwSemiBold,
                                                  color: constants.darkGrey,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Icon(
                                                Icons
                                                    .keyboard_arrow_down_rounded,
                                                size: 20,
                                                color: constants.darkGrey,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                content: Column(
                                  children: [
                                    SizedBox(height: 30),
                                    if (widget.toggle != null) ...[
                                      widget.toggle!,
                                      SizedBox(height: 20),
                                    ],
                                    if (widget.addButton != null ||
                                        widget.deleteButton != null) ...[
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (widget.addButton != null)
                                            widget.addButton!,
                                          if (widget.addButton != null &&
                                              widget.deleteButton != null)
                                            SizedBox(width: 16),
                                          if (widget.deleteButton != null)
                                            widget.deleteButton!,
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                    ],
                                    viewModel.getBlocksCount() == 0
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                              top: 40,
                                            ),
                                            child: Center(
                                              child: Text(
                                                textAlign: TextAlign.center,
                                                "No upcoming consultations found.",
                                                style: TextStyle(
                                                  fontWeight:
                                                      constants.fwSemiBold,
                                                  fontSize: constants.fsTitle,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: 30),
                                              ...() {
                                                final sortedEntries = viewModel
                                                    .slotsInBlocks
                                                    .entries
                                                    .toList();
                                                sortedEntries.sort((a, b) {
                                                  final blockA = viewModel
                                                      .blocks
                                                      .firstWhere(
                                                        (block) =>
                                                            block.id == a.key,
                                                      );
                                                  final blockB = viewModel
                                                      .blocks
                                                      .firstWhere(
                                                        (block) =>
                                                            block.id == b.key,
                                                      );
                                                  return blockA.date.compareTo(
                                                    blockB.date,
                                                  );
                                                });
                                                return sortedEntries.map((
                                                  block,
                                                ) {
                                                  return Center(
                                                    child: Column(
                                                      children: [
                                                        const SizedBox(
                                                          height: 20,
                                                        ),
                                                        Container(
                                                          clipBehavior:
                                                              Clip.hardEdge,
                                                          width:
                                                              MediaQuery.of(
                                                                context,
                                                              ).size.width *
                                                              0.9,
                                                          decoration: constants
                                                              .squircleShadow(
                                                                border: Border.all(
                                                                  color:
                                                                      constants
                                                                          .grey,
                                                                  width: 0.2,
                                                                ),
                                                                color: constants
                                                                    .background,
                                                              ),
                                                          child: Column(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets.fromLTRB(
                                                                      20,
                                                                      10,
                                                                      20,
                                                                      10,
                                                                    ),
                                                                child: Stack(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                      viewModel
                                                                          .blockDateLabel(
                                                                            block.key,
                                                                          ),
                                                                      style: TextStyle(
                                                                        color: constants
                                                                            .darkGrey,
                                                                        fontSize:
                                                                            constants.fsLabel,
                                                                        fontWeight:
                                                                            constants.fwSemiBold,
                                                                      ),
                                                                    ),
                                                                    if (widget
                                                                            .editBlockButton !=
                                                                        null)
                                                                      Align(
                                                                        alignment:
                                                                            Alignment.centerRight,
                                                                        child: widget.editBlockButton!(
                                                                          block
                                                                              .key,
                                                                        ),
                                                                      ),
                                                                  ],
                                                                ),
                                                              ),
                                                              ListView.builder(
                                                                physics:
                                                                    const NeverScrollableScrollPhysics(),
                                                                shrinkWrap:
                                                                    true,
                                                                padding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                itemCount: block
                                                                    .value!
                                                                    .length,
                                                                itemBuilder: (context, index) {
                                                                  final slot = block
                                                                      .value![index];
                                                                  final isFirst =
                                                                      index ==
                                                                      0;
                                                                  final isLast =
                                                                      index ==
                                                                      block.value!.length -
                                                                          1;
                                                                  return SlotWidget(
                                                                    userEmail:
                                                                        widget
                                                                            .email,
                                                                    slot: slot,
                                                                    token: widget
                                                                        .token,
                                                                    roomId: viewModel
                                                                        .selectedRoomId!,
                                                                    context:
                                                                        context,
                                                                    loadData: () =>
                                                                        viewModel.loadRoom(
                                                                          widget
                                                                              .token,
                                                                        ),
                                                                    isFirst:
                                                                        isFirst,
                                                                    isLast:
                                                                        isLast,
                                                                    date: viewModel
                                                                        .blockDateLabel(
                                                                          block
                                                                              .key,
                                                                        ),
                                                                  );
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList();
                                              }(),
                                            ],
                                          ),
                                  ],
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
    );
  }
}
