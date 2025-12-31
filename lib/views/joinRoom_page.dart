import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/utils/constants.dart';
import 'package:consultation_app/utils/helperFunctions.dart';
import 'package:consultation_app/utils/notifyUserUtils.dart';
import 'package:consultation_app/viewmodels/consultations_viewmodel.dart';
import 'package:consultation_app/viewmodels/joinRoom_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/appBarMenu_widget.dart';
import 'package:consultation_app/views/custom_widgets/sliderMenu_widget.dart';
import 'package:flutter/material.dart';

class JoinRoom extends StatefulWidget {
  final String token;
  const JoinRoom({super.key, required this.token});

  @override
  State<JoinRoom> createState() => _JoinRoomState();
}

class _JoinRoomState extends State<JoinRoom> {
  final Constants _constants = Constants();
  HelperFunctions helperFunctions = HelperFunctions();
  NotifyUserUtils dialogs = NotifyUserUtils();
  JoinRoomViewmodel _jrvm = JoinRoomViewmodel();
  String? selectedRoomId;
  List<RoomModel>? allRooms = [];
  int? selectedId;
  final TextEditingController idController = TextEditingController();
  final ConsultationsViewmodel _consultationsViewmodel =
      ConsultationsViewmodel();
  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await _consultationsViewmodel.fetchAllRooms(widget.token);

    setState(() {
      allRooms = _consultationsViewmodel.allRooms;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarMenu(),
      drawer: SliderMenu(),
      backgroundColor: _constants.bgLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 50),
                Text("Join Room"),
                SizedBox(height: 20),
                DropdownButton<String>(
                  hint: Text("Select a Room"),
                  value: selectedRoomId,
                  items: (allRooms == null)
                      ? []
                      : allRooms!.map((RoomModel value) {
                          return DropdownMenuItem<String>(
                            value: value.id.toString(),
                            child: Text(value.title),
                          );
                        }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedRoomId = newValue;
                      selectedId = int.tryParse(newValue!) ?? -1;
                    });
                    loadData();
                  },
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (selectedId != -1) {
                        await _jrvm.joinRoom(
                          context,
                          widget.token,
                          selectedId!,
                        );
                      } else {
                        dialogs.showToast('Select room to join');
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        _constants.primaryColor,
                      ),
                    ),
                    child: const Text(
                      'Next',
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
        ),
      ),
    );
  }
}
