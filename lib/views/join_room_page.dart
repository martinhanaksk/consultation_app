import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/join_room_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:figma_squircle/figma_squircle.dart';

class JoinRoom extends StatefulWidget {
  final String token;
  const JoinRoom({super.key, required this.token});

  @override
  State<JoinRoom> createState() => _JoinRoomState();
}

class _JoinRoomState extends State<JoinRoom> {
  String? selectedRoomId;
  int? selectedId;
  final TextEditingController idController = TextEditingController();

  late final JoinRoomViewmodel _viewModel;
  @override
  void initState() {
    super.initState();
    _viewModel = JoinRoomViewmodel();
    _viewModel.fetchAllRooms(widget.token);
    _viewModel.fetchJoinedRooms(widget.token);
  }

  @override
  void dispose() {
    idController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  final dropDownKey = GlobalKey<DropdownSearchState>();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<JoinRoomViewmodel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBarMenu(),
            drawer: SliderMenu(),
            backgroundColor: constants.background,
            body: SafeArea(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  reverse: true,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 48),
                          Center(
                            child: Text(
                              "Join a Room",
                              style: TextStyle(
                                fontWeight: constants.fwSemiBold,
                                fontSize: constants.fsHeadline,color: constants.darkGrey
                              ),
                            ),
                          ),
                          SizedBox(height: 24),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: constants.squircleShadow(
                              color: constants.background,
                              borderRadius: SmoothBorderRadius(
                                cornerRadius: 20,
                                cornerSmoothing: 0.6,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text(
                                    "Browse and join rooms",
                                    style: TextStyle(
                                      fontWeight: constants.fwRegular,
                                      fontSize: constants.fsLabel,
                                      color: constants.darkGrey200,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Autocomplete<RoomModel>(
                                  displayStringForOption: (RoomModel option) =>
                                      option.title,
                                  optionsBuilder:
                                      (TextEditingValue textEditingValue) {
                                        final rooms =
                                            viewModel.allRooms() ?? [];
                                        if (textEditingValue.text.isEmpty) {
                                          return rooms;
                                        }

                                        return rooms.where((RoomModel room) {
                                          return room.title
                                              .toLowerCase()
                                              .contains(
                                                textEditingValue.text
                                                    .toLowerCase(),
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
                                          scrollPadding: EdgeInsets.only(
                                            bottom:
                                                MediaQuery.of(
                                                  context,
                                                ).viewInsets.bottom +
                                                20,
                                          ),
                                          controller: roomController,
                                          focusNode: focusNode,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: constants.grey,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: constants.grey,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: constants.primary,
                                                width: 1.5,
                                              ),
                                            ),
                                            hintText: 'Type to search rooms...',
                                            prefixIcon: Padding(
                                              padding: const EdgeInsets.all(
                                                12.0,
                                              ),
                                              child: svgs.icon(
                                                'search',constants.darkGrey150,
                                                width: constants.fsLabel,
                                                 
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                  optionsViewBuilder:
                                      (
                                        BuildContext context,
                                        AutocompleteOnSelected<RoomModel>
                                        onSelected,
                                        Iterable<RoomModel> options,
                                      ) {
                                        return Align(
                                          alignment: Alignment.topLeft,
                                          child: Material(
                                            color: constants.transparent,
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                top: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: constants.background,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: constants.darkGrey30,
                                                    blurRadius: 12,
                                                    spreadRadius: 2,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              constraints: const BoxConstraints(
                                                maxHeight: 200,
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                child: ListView.builder(
                                                  padding: EdgeInsets.zero,
                                                  shrinkWrap: true,
                                                  itemCount: options.length,
                                                  itemBuilder:
                                                      (
                                                        BuildContext context,
                                                        int index,
                                                      ) {
                                                        final RoomModel option =
                                                            options.elementAt(
                                                              index,
                                                            );
                                                        final bool isSelected =
                                                            option.id
                                                                .toString() ==
                                                            selectedRoomId;

                                                        if (viewModel
                                                            .isInJoinedRooms(
                                                              option,
                                                            )) {
                                                          return const SizedBox.shrink();
                                                        }

                                                        return InkWell(
                                                          onTap: () =>
                                                              onSelected(
                                                                option,
                                                              ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      20,
                                                                  vertical: 4,
                                                                ),
                                                            child: ListTile(
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              title: Text(
                                                                option.title,
                                                                style: TextStyle(
                                                                  fontSize: constants.fsLabel,
                                                                  fontWeight:
                                                                      constants
                                                                          .fwRegular,
                                                                  color: constants
                                                                      .darkGrey,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                ),
                                const SizedBox(height: 32),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      FocusScope.of(context).unfocus();
                                      if (selectedId != null) {
                                        await viewModel.joinRoom(
                                          widget.token,
                                          selectedId!,
                                        );
                                      } else {
                                        notify.showToast('Select room to join');
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: constants.primary,
                                      disabledBackgroundColor:
                                          constants.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 2,
                                      shadowColor: constants.lightPrimary,
                                    ),
                                    child: Text(
                                      'Join room',
                                      style: TextStyle(
                                        fontSize: constants.fsBody,
                                        fontWeight: constants.fwSemiBold,
                                        color: constants.background,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
