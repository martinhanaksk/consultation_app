import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/viewmodels/student_consultations_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/slot_widget.dart';
import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';
import 'package:provider/provider.dart';

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
    final _viewModel = context.watch<StudentConsultationsViewmodel>();
    return Scaffold(
      appBar: AppBarMenu(),
      drawer: SliderMenu(),
      backgroundColor: constants.darkWhite,
      body: SafeArea(
        child: _viewModel.isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                  strokeWidth: 3,
                ),
              )
            : (_viewModel.hasNoRooms || _viewModel.selectedRoomId == null)
            ? Padding(
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
                            fontSize: constants.fontSizeMedium,
                            color: constants.primary,
                          ),
                        ),
                        onTap: () => nav.toJoinRoom(token: widget.token),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 80),
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: constants.lightGrey,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          borderRadius: BorderRadius.circular(20.0),
                          dropdownColor: constants.lightGrey,
                          iconEnabledColor: constants.darkGrey,
                          hint: Text("Select a Room"),
                          value: _viewModel.safeSelectedRoomId,
                          items: _viewModel.rooms == null
                              ? []
                              : _viewModel.rooms!.map((RoomModel value) {
                                  return DropdownMenuItem<String>(
                                    value: value.id.toString(),
                                    child: Text(value.title),
                                  );
                                }).toList(),
                          onChanged: (String? newValue) async {
                            if (newValue != null) {
                              final success = await _viewModel.setSelectedId(
                                newValue,
                              );
                              if (success) {
                                await _viewModel.onRoomChanged(newValue);
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 80),
                  Center(
                    child: Text(
                      "Write your self here",
                      style: TextStyle(
                        color: constants.darkGrey,
                        fontSize: constants.fontSizeBig,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  _viewModel.foundBlocksLength() == 0
                      ? Center(
                          child: Text(
                            "No upcoming consultations found.",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: constants.fontSizeSmall,
                            ),
                          ),
                        )
                      : Expanded(
                          child: ListView(
                            children: () {
                              final sortedEntries = _viewModel
                                  .slotsInBlocks
                                  .entries
                                  .toList();
                              sortedEntries.sort((a, b) {
                                final blockA = _viewModel.blocks.firstWhere(
                                  (block) => block.id == a.key,
                                );
                                final blockB = _viewModel.blocks.firstWhere(
                                  (block) => block.id == b.key,
                                );

                                return blockA.date.compareTo(blockB.date);
                              });
                              return sortedEntries.map((block) {
                                return Column(
                                  children: [
                                    const SizedBox(height: 20),
                                    Text(
                                      _viewModel.getDateOfBlock(block.key),
                                      style: TextStyle(
                                        color: constants.darkGrey,
                                        fontSize: constants.fontSizeSmall,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    (block.value == null ||
                                            block.value!.isEmpty)
                                        ? Text("No slots found")
                                        : Container(
                                            clipBehavior: Clip.hardEdge,
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.shade600,
                                                  spreadRadius: 1,
                                                  blurRadius: 10,
                                                  offset: const Offset(2, 2),
                                                ),
                                                const BoxShadow(
                                                  color: Colors.white,
                                                  offset: Offset(-5, -5),
                                                  blurRadius: 15,
                                                  spreadRadius: 1,
                                                ),
                                              ],

                                              color: Colors.white,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(20),
                                              ),
                                            ),
                                            child: Column(
                                              children: block.value!
                                                  .asMap()
                                                  .entries
                                                  .map((entry) {
                                                    final index = entry.key;
                                                    final slot = entry.value;

                                                    if (slot == null) {
                                                      return Text(
                                                        "No slots for the block found.",
                                                      );
                                                    }

                                                    final isFirst = index == 0;
                                                    final isLast =
                                                        index ==
                                                        block.value!.length - 1;

                                                    return SlotWidget(
                                                      userEmail: widget.email,
                                                      slot: slot,
                                                      token: widget.token,
                                                      roomId: _viewModel
                                                          .selectedRoomId!,
                                                      context: context,
                                                      loadData:
                                                          _viewModel.loadData,
                                                      isFirst: isFirst,
                                                      isLast: isLast,
                                                    );
                                                  })
                                                  .toList(),
                                            ),
                                          ),
                                  ],
                                );
                              }).toList();
                            }(),
                          ),
                        ),
                ],
              ),
      ),
    );
  }
}
