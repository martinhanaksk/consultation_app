// join_room_page.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Allows students to search all available rooms and join one.
// Also displays the list of rooms the student has already joined.

import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/join_room_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/custom_text_field_widget.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:figma_squircle/figma_squircle.dart';

class JoinRoom extends StatefulWidget {
  const JoinRoom({super.key});

  @override
  State<JoinRoom> createState() => _JoinRoomState();
}

class _JoinRoomState extends State<JoinRoom> {
  late final JoinRoomViewmodel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = JoinRoomViewmodel();
    _viewModel.init();
  }

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
                // Dismisses the keyboard when tapping outside any input field
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
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
                                fontSize: constants.fsHeadline,
                                color: constants.darkGrey,
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
                                        // Shows all rooms when the field is empty,
                                        // otherwise filters by title substring
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
                                  onSelected: (RoomModel room) {
                                    viewModel.setSelectedIds(room);
                                  },
                                  fieldViewBuilder:
                                      (
                                        BuildContext context,
                                        TextEditingController roomController,
                                        FocusNode focusNode,
                                        VoidCallback onFieldSubmitted,
                                      ) {
                                        return CustomInputTextField(
                                          onChanged: (value) {
                                            final rooms =
                                                viewModel.allRooms() ?? [];
                                            // Checks for match on every keystroke
                                            // so the selection stays valid when the user
                                            // types a full room title without picking from the list
                                            final match = rooms
                                                .cast<RoomModel?>()
                                                .firstWhere(
                                                  (room) =>
                                                      room!.title
                                                          .toLowerCase() ==
                                                      value.toLowerCase(),
                                                  orElse: () => null,
                                                );

                                            if (match != null) {
                                              viewModel.setSelectedIds(match);
                                            } else {
                                              viewModel.clearSelection();
                                            }
                                          },
                                          focusNode: focusNode,
                                          controller: roomController,
                                          maxLength: 50,
                                          hintText: 'Type to search rooms...',
                                          prefixIcon: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: svgs.icon(
                                              'search',
                                              constants.darkGrey150,
                                              width: constants.fsLabel,
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
                                              decoration: constants
                                                  .squircleShadow(
                                                    color: constants.background,
                                                    hasBorder: true,
                                                  ),
                                              constraints: const BoxConstraints(
                                                maxHeight: 200,
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                child: ScrollConfiguration(
                                                  behavior:
                                                      ScrollConfiguration.of(
                                                        context,
                                                      ).copyWith(
                                                        physics:
                                                            const BouncingScrollPhysics(
                                                              parent:
                                                                  AlwaysScrollableScrollPhysics(),
                                                            ),
                                                        overscroll: false,
                                                      ),
                                                  child: ScrollConfiguration(
                                                    behavior:
                                                        ScrollConfiguration.of(
                                                          context,
                                                        ).copyWith(
                                                          physics:
                                                              const BouncingScrollPhysics(
                                                                parent:
                                                                    AlwaysScrollableScrollPhysics(),
                                                              ),
                                                          overscroll: false,
                                                        ),
                                                    child: ListView.builder(
                                                      padding: EdgeInsets.zero,
                                                      shrinkWrap: true,
                                                      itemCount: options.length,
                                                      itemBuilder:
                                                          (
                                                            BuildContext
                                                            context,
                                                            int index,
                                                          ) {
                                                            final RoomModel
                                                            option = options
                                                                .elementAt(
                                                                  index,
                                                                );
                                                            // Rooms the student has already joined
                                                            // are excluded from the dropdown list
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
                                                                      vertical:
                                                                          4,
                                                                    ),
                                                                child: ListTile(
                                                                  contentPadding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                  title: Text(
                                                                    option
                                                                        .title,
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          constants
                                                                              .fsLabel,
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
                                      if (viewModel.selectedId != null) {
                                        await viewModel.joinRoom(
                                          viewModel.selectedId!,
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
                          const SizedBox(height: 28),
                          Center(
                            child: Text(
                              "Rooms joined",
                              style: TextStyle(
                                fontWeight: constants.fwSemiBold,
                                fontSize: constants.fsBody,
                                color: constants.darkGrey,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Three states: loading spinner, empty message, or room list
                          viewModel.isLoadingRooms
                              ? Center(
                                  child: SpinKitPouringHourGlass(
                                    color: constants.primary,
                                    size: constants.fsHeadline,
                                  ),
                                )
                              : viewModel.joinedRooms() == null ||
                                    viewModel.joinedRooms()!.isEmpty
                              ? Center(
                                  child: Text(
                                    "You haven't joined any rooms yet.",
                                    style: TextStyle(
                                      fontSize: constants.fsLabel,
                                      color: constants.darkGrey200,
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,

                                  itemCount: viewModel.joinedRooms()!.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final room = viewModel
                                        .joinedRooms()![index];
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 16,
                                      ),
                                      decoration: constants.squircleShadow(
                                        color: constants.background,
                                        borderRadius: SmoothBorderRadius(
                                          cornerRadius: 16,
                                          cornerSmoothing: 0.6,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          svgs.icon(
                                            'student',
                                            constants.primary,
                                            width: constants.fsBody,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              room.title,
                                              style: TextStyle(
                                                fontSize: constants.fsLabel,
                                                fontWeight:
                                                    constants.fwSemiBold,
                                                color: constants.darkGrey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                          const SizedBox(height: 24),
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
