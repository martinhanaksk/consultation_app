import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/viewmodels/teacher_consultations_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/animated_toggle_widget.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/slot_widget.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ConsultationsTeacherPageArgs {
  final String token;
  final String email;
  ConsultationsTeacherPageArgs({required this.token, required this.email});
}

class ConsultationsTeacherPage extends StatelessWidget {
  final String token;
  final String email;
  const ConsultationsTeacherPage({
    super.key,
    required this.token,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TeacherConsultationsViewmodel(),
      child: _ConsultationsTeacherPageInner(token: token, email: email),
    );
  }
}

class _ConsultationsTeacherPageInner extends StatefulWidget {
  final String token;
  final String email;
  const _ConsultationsTeacherPageInner({
    required this.token,
    required this.email,
  });

  @override
  State<_ConsultationsTeacherPageInner> createState() =>
      _ConsultationsUserPageState();
}

class _ConsultationsUserPageState
    extends State<_ConsultationsTeacherPageInner> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<TeacherConsultationsViewmodel>();
      viewModel.init(widget.token, widget.email);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TeacherConsultationsViewmodel>();
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
                            onTap: () => nav.toJoinRoom(token: widget.token),
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
                      overscroll: false, // removes the stretch glow
                    ),
                    child: ListView(
                      children: [
                        SizedBox(height: 100),
                        StickyHeader(
                          header: Container(
                            color: constants.background,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: Center(
                              child: PopupMenuButton<String>(
                                position: PopupMenuPosition.under,
                                offset: const Offset(0, 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: constants.grey,
                                elevation: 12,
                                shadowColor: constants.darkGrey.withValues(
                                  alpha: 0.12,
                                ),
                                onSelected: (String newValue) async {
                                  final success = await viewModel
                                      .validateAndSelectRoom(newValue);
                                  if (success) {
                                    await viewModel.switchRoom(newValue);
                                  }
                                },
                                itemBuilder: (context) =>
                                    viewModel.rooms == null
                                    ? []
                                    : viewModel.rooms!.map((RoomModel value) {
                                        final isSelected =
                                            value.id.toString() ==
                                            viewModel.safeSelectedRoomId;
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
                                                      r!.id.toString() ==
                                                      viewModel
                                                          .safeSelectedRoomId,
                                                  orElse: () => null,
                                                )
                                                ?.title ??
                                            "Select a Room",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: constants.fwSemiBold,
                                          color: constants.darkGrey,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 20,
                                        color: constants.darkGrey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          content: Column(
                            children: [
                              SizedBox(height: 30),
                              AnimatedToggle(
                                isAdmin: viewModel.adminView == 1
                                    ? true
                                    : false,
                                values: ['Admin', 'Reserver'],
                                onToggleCallback: (value) {
                                  viewModel.toggleView(widget.token, value);
                                },
                                width: 200,
                                height: 50,
                                buttonColor: constants.primary,
                                backgroundColor: constants.grey,
                                textColor: constants.background,
                              ),
                              SizedBox(height: 40),
                              Center(
                                child: Container(
                                  width: 300,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      viewModel.adminView == 1
                                          ? GestureDetector(
                                              child: Container(
                                                padding: EdgeInsets.all(10),
                                                decoration: constants
                                                    .squircleShadow(
                                                      color: constants.grey,
                                                    ),
                                                child: Icon(
                                                  Icons.add,
                                                  size: 25,
                                                  color: constants.darkGrey,
                                                ),
                                              ),
                                              onTap: () {
                                                nav.toCreateBlock(
                                                  token: widget.token,
                                                  roomId: viewModel
                                                      .safeSelectedRoomId!,
                                                );
                                              },
                                            )
                                          : SizedBox.shrink(),

                                      viewModel.adminView == 1
                                          ? GestureDetector(
                                              child: Container(
                                                padding: EdgeInsets.all(10),
                                                decoration: constants
                                                    .squircleShadow(
                                                      color: constants.grey,
                                                    ),
                                                child: Icon(
                                                  Icons.delete_outline_rounded,
                                                  size: 25,
                                                  color: constants.darkGrey,
                                                ),
                                              ),
                                              onTap: () {
                                                viewModel.deleteRoom(
                                                  widget.token,
                                                );
                                              },
                                            )
                                          : SizedBox.shrink(),
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: constants.squircleShadow(
                                          color: constants.grey,
                                        ),
                                        child: Icon(
                                          Icons.more_horiz,
                                          size: 25,
                                          color: constants.darkGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              viewModel.getBlocksCount() == 0
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 20),
                                      child: Center(
                                        child: Text(
                                          "No upcoming consultations found.",
                                          style: TextStyle(
                                            fontWeight: constants.fwSemiBold,
                                            fontSize: constants.fsLabel,
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
                                            final blockA = viewModel.blocks
                                                .firstWhere(
                                                  (block) => block.id == a.key,
                                                );
                                            final blockB = viewModel.blocks
                                                .firstWhere(
                                                  (block) => block.id == b.key,
                                                );
                                            return blockA.date.compareTo(
                                              blockB.date,
                                            );
                                          });

                                          return sortedEntries.map((block) {
                                            return Center(
                                              child: Column(
                                                children: [
                                                  const SizedBox(height: 20),
                                                  Container(
                                                    clipBehavior: Clip.hardEdge,
                                                    width:
                                                        MediaQuery.of(
                                                          context,
                                                        ).size.width *
                                                        0.9,
                                                    decoration: constants
                                                        .squircleShadow(
                                                          border: Border.all(
                                                            color:
                                                                constants.grey,
                                                            width: 0.2,
                                                          ),

                                                          color: constants
                                                              .background,
                                                        ),
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.fromLTRB(
                                                                  20,
                                                                  10,
                                                                  20,
                                                                  10,
                                                                ),
                                                            child: Text(
                                                              viewModel
                                                                  .blockDateLabel(
                                                                    block.key,
                                                                  ),
                                                              style: TextStyle(
                                                                color: constants
                                                                    .darkGrey,
                                                                fontSize:
                                                                    constants
                                                                        .fsLabel,
                                                                fontWeight:
                                                                    constants
                                                                        .fwSemiBold,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        ListView.builder(
                                                          physics:
                                                              const NeverScrollableScrollPhysics(),
                                                          shrinkWrap: true,
                                                          padding:
                                                              EdgeInsets.zero,
                                                          itemCount: block
                                                              .value!
                                                              .length,
                                                          itemBuilder: (context, index) {
                                                            final slot = block
                                                                .value![index];
                                                            final isFirst =
                                                                index == 0;
                                                            final isLast =
                                                                index ==
                                                                block
                                                                        .value!
                                                                        .length -
                                                                    1;
                                                            return SlotWidget(
                                                              userEmail:
                                                                  widget.email,
                                                              slot: slot,
                                                              token:
                                                                  widget.token,
                                                              roomId: viewModel
                                                                  .selectedRoomId!,
                                                              context: context,
                                                              loadData: () {
                                                                viewModel
                                                                    .loadRoom(
                                                                      widget
                                                                          .token,
                                                                    );
                                                              },
                                                              isFirst: isFirst,
                                                              isLast: isLast,
                                                              date: viewModel
                                                                  .blockDateLabel(
                                                                    block.key,
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
  }
}
