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

// Provider wrapper sits outside so the inner widget's context can access it
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
  bool isLoading = false;
  late final StudentConsultationsViewmodel _viewModel;
  @override
  void initState() {
    super.initState();
    _viewModel = StudentConsultationsViewmodel();
    _viewModel.init(widget.token, widget.email);
    print("inited");
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    if (_viewModel.selectedRoomId == null) {
      await _viewModel.init(widget.token, widget.email);
    }

    await _viewModel.loadRoom(
      widget.token,
      int.parse(_viewModel.selectedRoomId!),
    );
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> onRoomChanged(String newRoomId) async {
    setState(() => isLoading = true);
    await _viewModel.loadRoom(widget.token, int.parse(newRoomId));
    if (mounted) setState(() => isLoading = false);
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
                            color: constants.primaryColor,
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
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        borderRadius: BorderRadius.circular(20.0),
                        dropdownColor: constants.defaultLightGrey,
                        iconEnabledColor: constants.defaultDarkGrey,
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
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            onRoomChanged(newValue);
                          } else {}
                        },
                      ),
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
                    child: ListView(
                      children: () {
                        final sortedEntries = _viewModel.slotsInBlocks.entries
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
                          return _viewModel.foundBlocksLength() == 0
                              ? Text("No upcoming consultations found.")
                              : Column(
                                  children: [
                                    Text(
                                      _viewModel.getDateOfBlock(block.key),
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
                                                            token: widget.token,
                                                            roomId: _viewModel
                                                                .selectedRoomId!,
                                                            context: context,
                                                            loadData: loadData,
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
