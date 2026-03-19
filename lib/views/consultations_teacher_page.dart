import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/viewmodels/teacher_consultations_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/slot_widget.dart';
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
      final _viewModel = context.read<TeacherConsultationsViewmodel>();
      _viewModel.init(widget.token, widget.email);
      _viewModel.loadData();
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
            : (viewModel.hasNoRooms || viewModel.selectedRoomId == null)
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
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50.0),
                                color: constants.grey,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  borderRadius: BorderRadius.circular(20.0),
                                  dropdownColor: constants.grey,
                                  iconSize: 0,
                                  hint: Text("Select a Room"),
                                  value: viewModel.safeSelectedRoomId,
                                  items: viewModel.rooms == null
                                      ? []
                                      : viewModel.rooms!.map((RoomModel value) {
                                          return DropdownMenuItem<String>(
                                            value: value.id.toString(),
                                            child: Text(value.title),
                                          );
                                        }).toList(),
                                  onChanged: (String? newValue) async {
                                    if (newValue != null) {
                                      final success = await viewModel
                                          .setSelectedId(newValue);
                                      if (success) {
                                        await viewModel.onRoomChanged(newValue);
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        content: Column(
                          children: [
                            SizedBox(height: 40),
                            Center(
                              child: Container(
                                width: 300,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    GestureDetector(
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: constants.grey,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(50),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          size: 25,
                                          color: constants.darkGrey,
                                        ),
                                      ),
                                      onTap: () {},
                                    ),

                                    GestureDetector(
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: constants.grey,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(50),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.delete_outline_rounded,
                                          size: 25,
                                          color: constants.darkGrey,
                                        ),
                                      ),
                                      onTap: () {
                                        viewModel.deleteRoom(widget.token);
                                      },
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: constants.grey,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(50),
                                        ),
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
                            viewModel.foundBlocksLength() == 0
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
                                                Text(
                                                  viewModel.getDateOfBlock(
                                                    block.key,
                                                  ),
                                                  style: TextStyle(
                                                    color: constants.darkGrey,
                                                    fontSize: constants.fsLabel,
                                                    fontWeight:
                                                        constants.fwRegular,
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                (block.value == null ||
                                                        block.value!.isEmpty)
                                                    ? Text("No slots found")
                                                    : Container(
                                                        clipBehavior:
                                                            Clip.hardEdge,
                                                        width:
                                                            MediaQuery.of(
                                                              context,
                                                            ).size.width *
                                                            0.9,
                                                        decoration: BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .grey
                                                                  .shade600,
                                                              spreadRadius: 1,
                                                              blurRadius: 10,
                                                              offset:
                                                                  const Offset(
                                                                    2,
                                                                    2,
                                                                  ),
                                                            ),
                                                            BoxShadow(
                                                              color: constants
                                                                  .background,
                                                              offset: Offset(
                                                                -5,
                                                                -5,
                                                              ),
                                                              blurRadius: 15,
                                                              spreadRadius: 1,
                                                            ),
                                                          ],
                                                          color: constants
                                                              .background,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                Radius.circular(
                                                                  20,
                                                                ),
                                                              ),
                                                        ),
                                                        child: ListView.builder(
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
                                                              loadData:
                                                                  viewModel
                                                                      .loadData,
                                                              isFirst: isFirst,
                                                              isLast: isLast,
                                                              date: viewModel
                                                                  .getDateOfBlock(
                                                                    block.key,
                                                                  ),
                                                            );
                                                          },
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
    );
  }
}
