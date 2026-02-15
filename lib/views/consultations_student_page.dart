import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/models/slot_model.dart';
import 'package:consultation_app/viewmodels/consultations_viewmodel.dart';
import 'package:consultation_app/viewmodels/slot_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/slot_widget.dart';
import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

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
    helpers.checkIfValidToken(widget.token);
  }

  

  void _checkRole() async {
    if (!await helpers.handleIsInternetConnection()) {
      notify.showToast('Please connect to internet.');
    } else {
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
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });
    if (selectedRoom != null) {
      helpers.checkIfValidToken(widget.token);
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
      backgroundColor: constants.bgLight,
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
                            fontSize: constants.fontSizeMedium,
                            color: constants.primaryColor,
                          ),
                        ),
                        onTap: () => {
                          nav.toJoinRoom(token: widget.token),
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
                              constants.primaryColor,
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
                        color: constants.defaultDarkGrey,
                        fontSize: constants.fontSizeBig,
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
                                return _consultationsViewmodel.foundBlocksLength()==0?Text("No upcoming consultations found."):Column(
                                  children: [
                                    Text(
                                      _consultationsViewmodel.getDateOfBlock(
                                        block.key,
                                      ),
                                      style: TextStyle(
                                        color: constants.defaultDarkGrey,
                                        fontSize: constants.fontSizeSmall,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    SizedBox(height: 20),
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
