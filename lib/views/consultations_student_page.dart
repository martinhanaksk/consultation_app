import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/viewmodels/student_consultations_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/slot_widget.dart';
import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ConsultationsStudentPageArgs {
  final String token;
  final String email;
  ConsultationsStudentPageArgs({required this.token, required this.email});
}

class ConsultationsStudentPage extends StatelessWidget {
  final String token;
  final String email;
  const ConsultationsStudentPage({
    super.key,
    required this.token,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StudentConsultationsViewmodel(),
      child: _ConsultationsStudentPageInner(token: token, email: email),
    );
  }
}

class _ConsultationsStudentPageInner extends StatefulWidget {
  final String token;
  final String email;
  const _ConsultationsStudentPageInner({
    required this.token,
    required this.email,
  });

  @override
  State<_ConsultationsStudentPageInner> createState() =>
      _ConsultationsUserPageState();
}

class _ConsultationsUserPageState
    extends State<_ConsultationsStudentPageInner> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final _viewModel = context.read<StudentConsultationsViewmodel>();
      _viewModel.init(widget.token, widget.email);
      _viewModel.loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StudentConsultationsViewmodel>();
    return Scaffold(
      appBar: AppBarMenu(),
      drawer: SliderMenu(),
      backgroundColor: constants.background,
      body: SafeArea(
        child: viewModel.isLoading
            ? Center(
                child: SpinKitPouringHourGlass(
                  color: constants.primary,
                  size: 50.0,
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
                                    constants.background.withValues(alpha: 0.6),
                                    constants.background.withValues(alpha: 0.3),
                                    constants.background.withValues(alpha: 0.0),
                                  ],
                                  stops: const [0.0, 0.7, 0.8, 0.9, 1.0],
                                ),
                              ),
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 50),
                              child: Center(
                                child: Container(
                                  clipBehavior: Clip.none,
                                  padding: EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: constants.grey,
                                    borderRadius: BorderRadius.circular(20),
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
                                          : viewModel.rooms!.map((
                                              RoomModel value,
                                            ) {
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
                                            await viewModel.onRoomChanged(
                                              newValue,
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          content: viewModel.foundBlocksLength() == 0
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 40),
                                  child: Center(
                                    child: Text(
                                      "No upcoming consultations found.",
                                      style: TextStyle(
                                        fontWeight: constants.fwSemiBold,
                                        fontSize: constants.fsTitle,
                                      ),
                                    ),
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                                  fontWeight: constants.fwRegular,
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
                                                      decoration: constants
                                                          .figmaLightShadowWith(
                                                            borderRadius:
                                                                SmoothBorderRadius(
                                                                  cornerRadius:
                                                                      20,
                                                                  cornerSmoothing:
                                                                      0.6,
                                                                ),
                                                            color: constants
                                                                .background,
                                                          ),
                                                      child: ListView.builder(
                                                        physics:
                                                            const NeverScrollableScrollPhysics(),
                                                        shrinkWrap: true,
                                                        padding:
                                                            EdgeInsets.zero,
                                                        itemCount:
                                                            block.value!.length,
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
                                                            token: widget.token,
                                                            roomId: viewModel
                                                                .selectedRoomId!,
                                                            context: context,
                                                            loadData: viewModel
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
