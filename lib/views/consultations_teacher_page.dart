import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/viewmodels/teacher_consultations_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/slot_widget.dart';
import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';
import 'package:provider/provider.dart';

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
      _ConsultationsTeacherPageState();
}

class _ConsultationsTeacherPageState
    extends State<_ConsultationsTeacherPageInner> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => loadData());
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    await context.read<TeacherConsultationsViewmodel>().init(widget.token);
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> onRoomChanged(String newRoomId) async {
    setState(() => isLoading = true);
    await context.read<TeacherConsultationsViewmodel>().loadRoom(
      widget.token,
      int.parse(newRoomId),
    );
    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TeacherConsultationsViewmodel>();
    return Scaffold(
      appBar: AppBarMenu(),
      drawer: SliderMenu(),
      backgroundColor: constants.bgLight,
      body: SafeArea(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                  strokeWidth: 3,
                ),
              )
            : (vm.hasNoRooms || vm.selectedRoomId == null)
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
                            fontSize: constants.fontSizeBig,
                            color: constants.primaryColor,
                          ),
                        ),
                        onTap: () => nav.toJoinRoom(token: widget.token),
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        Column(
                          children: [
                            SizedBox(height: 150),
                            Center(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  color: constants.defaultLightGrey,
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    borderRadius: BorderRadius.circular(20.0),
                                    dropdownColor: constants.defaultLightGrey,
                                    iconEnabledColor: constants.defaultDarkGrey,
                                    hint: Text("Select a Room"),
                                    value:
                                         vm.safeSelectedRoomId,
                                    items: vm.rooms == null
                                        ? []
                                        : vm.rooms!.map((RoomModel value) {
                                            return DropdownMenuItem<String>(
                                              value: value.id.toString(),
                                              child: Text(
                                                value.title,
                                                style:
                                                    vm.selectedRoomId ==
                                                        value.id.toString()
                                                    ? TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                      )
                                                    : TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                              ),
                                            );
                                          }).toList(),
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        onRoomChanged(newValue);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                        ...() {
                          final sortedEntries = vm.slotsInBlocks.entries
                              .toList();
                          sortedEntries.sort((a, b) {
                            final blockA = vm.blocks.firstWhere(
                              (block) => block.id == a.key,
                            );
                            final blockB = vm.blocks.firstWhere(
                              (block) => block.id == b.key,
                            );
                            return blockA.date.compareTo(blockB.date);
                          });
                          return sortedEntries.map((block) {
                            return vm.foundBlocksLength() == 0
                                ? Text("No upcoming consultations found.")
                                : Column(
                                    children: [
                                      SizedBox(height: 10),
                                      Text(
                                        vm.getDateOfBlock(block.key),
                                        style: TextStyle(
                                          color: constants.defaultDarkGrey,
                                          fontSize: constants.fontSizeSmall,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      (block.value == null ||
                                              block.value!.isEmpty)
                                          ? Text("No slots found")
                                          : Container(
                                              clipBehavior: Clip.hardEdge,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(20),
                                                ),
                                              ),
                                              child: Column(
                                                children: block.value!
                                                    .map(
                                                      (slot) => slot == null
                                                          ? Text(
                                                              "No slots for the block found.",
                                                            )
                                                          : SlotWidget(
                                                              userEmail:
                                                                  widget.email,
                                                              slot: slot,
                                                              token:
                                                                  widget.token,
                                                              roomId: vm
                                                                  .selectedRoomId!,
                                                              context: context,
                                                              loadData:
                                                                  loadData,
                                                            ),
                                                    )
                                                    .toList(),
                                              ),
                                            ),
                                    ],
                                  );
                          }).toList();
                        }(),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
