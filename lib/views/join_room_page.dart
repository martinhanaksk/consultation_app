import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/consultations_viewmodel.dart';
import 'package:consultation_app/viewmodels/join_room_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:flutter/material.dart';

class JoinRoom extends StatefulWidget {
  final String token;
  const JoinRoom({super.key, required this.token});

  @override
  State<JoinRoom> createState() => _JoinRoomState();
}

class _JoinRoomState extends State<JoinRoom> {
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
      backgroundColor: constants.bgLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 50),
                Text(
                  "Join Room",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50),
                ),
                SizedBox(height: 20),

                Autocomplete<RoomModel>(
                  displayStringForOption: (RoomModel option) => option.title,
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return allRooms ?? [];
                    }
                    return (allRooms ?? []).where((RoomModel room) {
                      return room.title.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      );
                    });
                  },
                  onSelected: (RoomModel selection) {
                    setState(() {
                      selectedRoomId = selection.id.toString();
                      selectedId = selection.id;
                    });
                  },
                  fieldViewBuilder:
                      (
                        BuildContext context,
                        TextEditingController roomController,
                        FocusNode focusNode,
                        VoidCallback onFieldSubmitted,
                      ) {
                        return TextField(
                          controller: roomController,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            hintText: 'Room name',
                            border: OutlineInputBorder(),
                          ),
                        );
                      },
                  optionsViewBuilder:
                      (
                        BuildContext context,
                        AutocompleteOnSelected<RoomModel> onSelected,
                        Iterable<RoomModel> options,
                      ) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4.0,
                            child: Container(
                              constraints: BoxConstraints(maxHeight: 300),
                              child: ListView.builder(
                                padding: EdgeInsets.all(8.0),
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final RoomModel option = options.elementAt(
                                    index,
                                  );
                                  return GestureDetector(
                                    onTap: () {
                                      onSelected(option);
                                    },
                                    child: ListTile(title: Text(option.title)),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
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
                        notify.showToast('Select room to join');
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        constants.primaryColor,
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
