import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/models/slot_model.dart';
import 'package:consultation_app/viewmodels/consultations_viewmodel.dart';
import 'package:consultation_app/viewmodels/slot_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/slot_widget.dart';
import 'package:flutter/material.dart';
import 'package:consultation_app/setup.dart';

class ConsultationsTeacherPageArgs {
  final String token;
  final String email;
  ConsultationsTeacherPageArgs({required this.token, required this.email});
}

class ConsultationsTeacherPage extends StatefulWidget {
  final String token;
  final String email;
  const ConsultationsTeacherPage({
    super.key,
    required this.token,
    required this.email,
  });

  @override
  State<ConsultationsTeacherPage> createState() =>
      _ConsultationsUserPageState();
}

class _ConsultationsUserPageState extends State<ConsultationsTeacherPage> {
  final TextEditingController emailController = TextEditingController();
  final ConsultationsViewmodel _consultationsViewmodel =
      ConsultationsViewmodel();
  final SlotViewmodel _slotViewmodel = SlotViewmodel();
  Map<int, List<SlotModel?>?> slotsInBlocks = {};
  String? selectedRoom;
  String? firstRoom;
  List<RoomModel>? rooms = [];
  bool isLoading = false;
  bool isTeacher = false;
  String roomId = "";
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

  void loadData() async {
    setState(() {
      isLoading = true;
    });
    if (selectedRoom != null) {
      helpers.checkIfValidToken(widget.token);
      await _consultationsViewmodel.fetchData(
        widget.token,
        int.parse(selectedRoom!),
      );
    } else {
      helpers.checkIfValidToken(widget.token);
      await _consultationsViewmodel.fetchData(widget.token, 1);
    }

    setState(() {
      slotsInBlocks = _consultationsViewmodel.slotsInBlocks;
      rooms = _consultationsViewmodel.rooms;
      if (rooms != null) {
        if (rooms!.isNotEmpty) {
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
      }
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
            : (rooms != null && rooms!.isEmpty)
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
                        onTap: () => {nav.toJoinRoom(token: widget.token)},
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
                  Expanded(
                    child: isLoading
                        ? SizedBox.shrink()
                        : ListView(
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
                                        borderRadius: BorderRadius.circular(
                                          20.0,
                                        ),
                                        color: constants.defaultLightGrey,
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          borderRadius: BorderRadius.circular(
                                            20.0,
                                          ),
                                          dropdownColor:
                                              constants.defaultLightGrey,
                                          iconEnabledColor:
                                              constants.defaultDarkGrey,
                                          hint: Text("Select a Room"),
                                          value: selectedRoom,
                                          items: (rooms == null)
                                              ? []
                                              : rooms!.map((RoomModel value) {
                                                  return DropdownMenuItem<
                                                    String
                                                  >(
                                                    value: value.id.toString(),
                                                    child: Container(
                                                      child: Text(
                                                        value.title,
                                                        style:
                                                            selectedRoom ==
                                                                value.id
                                                                    .toString()
                                                            ? TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900,
                                                              )
                                                            : TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                      ),
                                                    ),
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
                                    ),
                                  ),

                                  SizedBox(height: 20),
                                ],
                              ),
                              ...() {
                                final sortedEntries = slotsInBlocks.entries
                                    .toList();

                                return sortedEntries.map((block) {
                                  return _consultationsViewmodel
                                              .foundBlocksLength() ==
                                          0
                                      ? Text("No upcoming consultations found.")
                                      : Column(
                                          children: [
                                            SizedBox(height: 10),
                                            Text(
                                              _consultationsViewmodel
                                                  .getDateOfBlock(block.key),
                                              style: TextStyle(
                                                color:
                                                    constants.defaultDarkGrey,
                                                fontSize:
                                                    constants.fontSizeSmall,
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
                                                      borderRadius:
                                                          BorderRadius.all(
                                                            Radius.circular(20),
                                                          ),
                                                    ),
                                                    child: Column(
                                                      children: block.value!
                                                          .map(
                                                            (slot) =>
                                                                slot == null
                                                                ? Text(
                                                                    "No slots for the block found.",
                                                                  )
                                                                : SlotWidget(
                                                                    userEmail:
                                                                        widget
                                                                            .email,
                                                                    slot: slot,
                                                                    token: widget
                                                                        .token,
                                                                    roomId:
                                                                        roomId,
                                                                    context:
                                                                        context,
                                                                    loadData: () =>
                                                                        loadData(),
                                                                  ),
                                                          )
                                                          .toList(),
                                                    ),
                                                  ),
                                          ],
                                        );
                                });
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
