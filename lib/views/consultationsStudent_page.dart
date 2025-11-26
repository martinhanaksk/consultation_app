import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/models/slot_model.dart';
import 'package:consultation_app/services/user_preferences.dart';
import 'package:consultation_app/utils/constants.dart';
import 'package:consultation_app/utils/helper_functions.dart';
import 'package:consultation_app/viewmodels/consultations_viewmodel.dart';
import 'package:consultation_app/viewmodels/slot_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/right_slider_menu.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/slot_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:overlay_kit/overlay_kit.dart';

class ConsultationsUserPageArgs {
  final String token;
  final String email;

  ConsultationsUserPageArgs({required this.token, required this.email});
}

class ConsultationsUserPage extends StatefulWidget {
  final String token;
  final String currentUserEmail;
  const ConsultationsUserPage({
    super.key,
    required this.token,
    required this.currentUserEmail,
  });

  @override
  State<ConsultationsUserPage> createState() => _ConsultationsUserPageState();
}

class _ConsultationsUserPageState extends State<ConsultationsUserPage> {
  final TextEditingController emailController = TextEditingController();
  final Constants _constants = Constants();
  HelperFunctions helperFunctions = HelperFunctions();
  final ConsultationsViewmodel _consultationsViewmodel =
      ConsultationsViewmodel();
  final SlotViewmodel _slotViewmodel = SlotViewmodel();
  Map<int, List<SlotModel?>?> slotsInBlocks = {};
  String selectedRoom = "1";
  List<RoomModel>? rooms = [];
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    loadData(selectedRoom);
  }

  void loadData(String roomId) async {
    setState(() {
      isLoading = true;
    });

    await _consultationsViewmodel.fetchData(widget.token, int.parse(roomId));

    setState(() {
      slotsInBlocks = _consultationsViewmodel.slotsInBlocks;
      rooms = _consultationsViewmodel.rooms;

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarMenu(),
      drawer: RightSliderMenu(),
      backgroundColor: _constants.bgLight,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
                strokeWidth: 3,
              ),
            )
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
                        selectedRoom = newValue!;
                      });
                      loadData(selectedRoom);
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
                SizedBox(height: 80),
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
                                  (block.value == null || block.value!.isEmpty)
                                      ? Text("No slots found")
                                      : Column(
                                          children: block.value!
                                              .map(
                                                (slot) => slot == null
                                                    ? Text(
                                                        "No slots for the block found.",
                                                      )
                                                    : SlotWidget(
                                                        userEmail: widget
                                                            .currentUserEmail,
                                                        slot: slot,
                                                        constants: _constants,
                                                        helperFunctions:
                                                            helperFunctions,
                                                        consultationsViewmodel:
                                                            _consultationsViewmodel,
                                                        slotViewmodel:
                                                            _slotViewmodel,
                                                        token: widget.token,
                                                        roomId: selectedRoom,
                                                        context: context,
                                                        loadData: () =>
                                                            loadData(
                                                              selectedRoom,
                                                            ),
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
    );
  }
}
