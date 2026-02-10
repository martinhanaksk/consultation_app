import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/models/slot_model.dart';
import 'package:consultation_app/routes/appRouter.dart';
import 'package:consultation_app/utils/constants.dart';
import 'package:consultation_app/utils/helperFunctions.dart';
import 'package:consultation_app/viewmodels/consultations_viewmodel.dart';
import 'package:consultation_app/viewmodels/slot_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/sliderMenu_widget.dart';
import 'package:consultation_app/views/custom_widgets/appBarMenu_widget.dart';
import 'package:consultation_app/views/custom_widgets/slot_widget.dart';
import 'package:flutter/material.dart';

class ConsultationsStudentPageArgs {
  final String token;
  final String email;

  ConsultationsStudentPageArgs({required this.token, required this.email});
}

class ConsultationsStudentPage extends StatefulWidget {
  final String token;
  final String email;
  const ConsultationsStudentPage({
    super.key,
    required this.token,
    required this.email,
  });

  @override
  State<ConsultationsStudentPage> createState() =>
      _ConsultationsUserPageState();
}

class _ConsultationsUserPageState extends State<ConsultationsStudentPage> {
  final TextEditingController emailController = TextEditingController();
  final Constants _constants = Constants();
  HelperFunctions helperFunctions = HelperFunctions();
  final ConsultationsViewmodel _consultationsViewmodel =
      ConsultationsViewmodel();
  final SlotViewmodel _slotViewmodel = SlotViewmodel();
  Map<int, List<SlotModel?>?> slotsInBlocks = {};
  String? selectedRoom;
  List<RoomModel>? rooms = [];
  String? firstRoom;
  String roomId = "";
  bool isLoading = false;
  bool isTeacher = false;
  @override
  void initState() {
    super.initState();
    _checkRole();
    loadData();
  }

  void _checkRole() async {
    bool result = await _consultationsViewmodel.isTeacher(
      widget.token,
      widget.email,
    );
    if (mounted) {
      setState(() {
        isTeacher = result;
      });
    }
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });
    if (selectedRoom != null) {
      await _consultationsViewmodel.fetchData(
        widget.token,
        int.parse(selectedRoom!),
      );
    }

    setState(() {
      slotsInBlocks = _consultationsViewmodel.slotsInBlocks;
      rooms = _consultationsViewmodel.rooms;
      if (rooms != null && rooms!.isNotEmpty) {
        firstRoom = rooms![0].id.toString();
        if (roomId == "") {
          if (firstRoom != null) {
            roomId = firstRoom!;
          }
          if (selectedRoom != null) {
            roomId = selectedRoom!;
          }
        }
        if (rooms!.isEmpty) {
          isLoading = false;
        }
      }
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarMenu(),
      drawer: SliderMenu(),
      backgroundColor: _constants.bgLight,
      body: SafeArea(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                  strokeWidth: 3,
                ),
              )
            : (rooms == null || rooms!.isEmpty || roomId == "")
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
                            fontSize: _constants.fontSizeMedium,
                            color: _constants.primaryColor,
                          ),
                        ),
                        onTap: () => {
                          Navigator.pushNamed(
                            context,
                            AppRouter.joinRoom,
                            arguments: {'token': widget.token},
                          ),
                        },
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            loadData();
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              _constants.primaryColor,
                            ),
                          ),
                          child: const Text(
                            'Refresh',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: Color(0xffffffff),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : roomId == ""
            ? Text("")
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 80),
                  Center(
                    child: DropdownButton<String>(
                      hint: Text("Select a Room"),
                      value: selectedRoom.toString(),
                      items: (rooms == null)
                          ? []
                          : rooms!.map((RoomModel value) {
                              return DropdownMenuItem<String>(
                                value: value.id.toString(),
                                child: Text(value.title),
                              );
                            }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          if (newValue != null) {
                            selectedRoom = newValue;
                            roomId = newValue;
                          }
                        });
                        loadData();
                      },
                    ),
                  ),

                  SizedBox(height: 80),
                  Center(
                    child: Text(
                      "Write your self here",
                      style: TextStyle(
                        color: _constants.defaultDarkGrey,
                        fontSize: _constants.fontSizeBig,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  Expanded(
                    child: isLoading
                        ? SizedBox.shrink()
                        : ListView(
                            children: () {
                              final sortedEntries = slotsInBlocks.entries
                                  .toList();
                              sortedEntries.sort((a, b) {
                                final blockA = _consultationsViewmodel.blocks
                                    .firstWhere((block) => block.id == a.key);
                                final blockB = _consultationsViewmodel.blocks
                                    .firstWhere((block) => block.id == b.key);
                                return blockA.date.compareTo(blockB.date);
                              });
                              return sortedEntries.map((block) {
                                return Column(
                                  children: [
                                    Text(
                                      _consultationsViewmodel.getDateOfBlock(
                                        block.key,
                                      ),
                                      style: TextStyle(
                                        color: _constants.defaultDarkGrey,
                                        fontSize: _constants.fontSizeSmall,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    (block.value == null ||
                                            block.value!.isEmpty)
                                        ? Text("No slots found")
                                        : Column(
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
                                                          constants: _constants,
                                                          helperFunctions:
                                                              helperFunctions,
                                                          consultationsViewmodel:
                                                              _consultationsViewmodel,
                                                          slotViewmodel:
                                                              _slotViewmodel,
                                                          token: widget.token,
                                                          roomId: roomId,
                                                          context: context,
                                                          loadData: () =>
                                                              loadData(),
                                                        ),
                                                )
                                                .toList(),
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
