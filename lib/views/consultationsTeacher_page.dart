import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/models/slot_model.dart';
import 'package:consultation_app/utils/constants.dart';
import 'package:consultation_app/utils/helperFunctions.dart';
import 'package:consultation_app/viewmodels/consultations_viewmodel.dart';
import 'package:consultation_app/viewmodels/slot_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/sliderMenu_widget.dart';
import 'package:consultation_app/views/custom_widgets/appBarMenu_widget.dart';
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
  HelperFunctions helperFunctions = HelperFunctions();
  final ConsultationsViewmodel _consultationsViewmodel =
      ConsultationsViewmodel();
  final SlotViewmodel _slotViewmodel = SlotViewmodel();
  Map<int, List<SlotModel?>?> slotsInBlocks = {};
  String? selectedRoom;
  List<RoomModel>? rooms = [];
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

  void loadData() async {
    setState(() {
      isLoading = true;
    });
    if (selectedRoom != null) {
      await _consultationsViewmodel.fetchData(
        widget.token,
        int.parse(selectedRoom!),
      );
    } else {
      await _consultationsViewmodel.fetchData(widget.token, 1);
    }

    setState(() {
      slotsInBlocks = _consultationsViewmodel.slotsInBlocks;
      rooms = _consultationsViewmodel.rooms;
      if (rooms != null) {
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
            : (rooms != null && rooms!.isEmpty)
            ? Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(height: 80),
                      Text(
                        "No rooms found.",
                        style: TextStyle(fontSize: _constants.fontSizeBig),
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
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 80),
                  Center(
                    child: DropdownButton<String>(
                      hint: Text("Select a Room"),
                      value: (rooms != null) ? selectedRoom : null,
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
                          selectedRoom = newValue!;
                        });
                        loadData();
                      },
                    ),
                  ),
                  SizedBox(height: 40),
                  Center(
                    child: Text(
                      "Slots",
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
                                                Radius.circular(10),
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
                                                            token: widget.token,
                                                            roomId:
                                                                selectedRoom ==
                                                                    null
                                                                ? "1"
                                                                : selectedRoom!,
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
