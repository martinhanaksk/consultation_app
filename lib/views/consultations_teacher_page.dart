import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/models/slot_model.dart';
import 'package:consultation_app/routes/app_router.dart';
import 'package:consultation_app/services/user_preferences.dart';
import 'package:consultation_app/utils/constants.dart';
import 'package:consultation_app/utils/helper_functions.dart';
import 'package:consultation_app/utils/notify_user_utils.dart';
import 'package:consultation_app/viewmodels/consultations_viewmodel.dart';
import 'package:consultation_app/viewmodels/slot_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/slot_widget.dart';
import 'package:flutter/material.dart';

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
  final Constants _constants = Constants();
  NotifyUserUtils dialogs = NotifyUserUtils();
  HelperFunctions helperFunctions = HelperFunctions();
  final ConsultationsViewmodel _consultationsViewmodel =
      ConsultationsViewmodel();
  UserPreferences _userPreferences = UserPreferences();
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
    checkIfValidToken();
  }

  void checkIfValidToken() async {
    if (widget.token == "") {
      await _userPreferences.removeItem('token');
      await _userPreferences.removeItem('email');
      await _userPreferences.removeItem('role');
      dialogs.showToast('Session expired.');
      // Navigate to login and clear all previous routes
      Navigator.pushNamed(context, AppRouter.login);
    }
  }

  void _checkRole() async {
    if (!await helperFunctions.handleIsInternetConnection()) {
      dialogs.showToast('Please connect to internet.');
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
    if (selectedRoom != null) { checkIfValidToken();
      await _consultationsViewmodel.fetchData(
        widget.token,
        int.parse(selectedRoom!),
      );
    } else { checkIfValidToken();
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
      backgroundColor: _constants.bgLight,
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
                            fontSize: _constants.fontSizeBig,
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
                                        color: _constants.defaultLightGrey,
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          borderRadius: BorderRadius.circular(
                                            20.0,
                                          ),
                                          dropdownColor:
                                              _constants.defaultLightGrey,
                                          iconEnabledColor:
                                              _constants.defaultDarkGrey,
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
                                      SizedBox(height: 10),
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
                                                              constants:
                                                                  _constants,
                                                              helperFunctions:
                                                                  helperFunctions,
                                                              consultationsViewmodel:
                                                                  _consultationsViewmodel,
                                                              slotViewmodel:
                                                                  _slotViewmodel,
                                                              token:
                                                                  widget.token,
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
