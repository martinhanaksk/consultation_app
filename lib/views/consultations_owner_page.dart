import 'package:consultation_app/viewmodels/owner_consultations_viewmodel.dart';
import 'package:consultation_app/views/consultations_base_page.dart';
import 'package:consultation_app/views/custom_widgets/animated_toggle_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:consultation_app/setup.dart';

class ConsultationsOwnerPage extends StatefulWidget {
  const ConsultationsOwnerPage({super.key});

  @override
  State<ConsultationsOwnerPage> createState() => _ConsultationsOwnerPageState();
}

class _ConsultationsOwnerPageState extends State<ConsultationsOwnerPage> {
  late final OwnerConsultationsViewmodel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = OwnerConsultationsViewmodel();
    initialize();
  }
  void initialize() async {
    try {
      await _viewModel.init();
    } catch (e) {
      notify.showToast('Something went wrong. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<OwnerConsultationsViewmodel>(
        builder: (context, viewModel, child) {
          final isOwner = viewModel.ownerView == 1;
          return BaseConsultationsPage(
            viewModel: viewModel,
            toggle: AnimatedToggle(
              isOwner: isOwner,
              values: const ['Owner', 'Visitor'],
              onToggleCallback: (value) => viewModel.toggleView(value),
              width: 150,
              height: 32,
              buttonColor: constants.primary,
              backgroundColor: constants.grey,
              textColor: constants.background,
            ),
            addButton: isOwner ? _AddBlockButton(viewModel: viewModel) : null,
            deleteButton: isOwner
                ? _SettingsDropdownButton(viewModel: viewModel)
                : null,
            editBlockButton: isOwner
                ? (blockId) =>
                      _EditBlockButton(blockId: blockId, viewModel: viewModel)
                : null,
            showHistoryOption: isOwner
                ? (slotId, blockId, color) => _ShowHistoryButton(
                    onHistoryClicked: () =>
                        viewModel.displayHistoryOfSlot(slotId, blockId),
                    color: color,
                  )
                : null,
            addSlotBefore: isOwner
                ? (blockId, isEmpty) => _AddSlotOnOutskirts(
                    viewModel: viewModel,
                    blockId: blockId,
                    isBefore: true,
                    isEmpty: isEmpty,
                  )
                : null,
            addSlotAfter: isOwner
                ? (blockId, isEmpty) => _AddSlotOnOutskirts(
                    viewModel: viewModel,
                    blockId: blockId,
                    isBefore: false,
                    isEmpty: isEmpty,
                  )
                : null,
          );
        },
      ),
    );
  }
}

class _AddSlotOnOutskirts extends StatelessWidget {
  final OwnerConsultationsViewmodel viewModel;
  final int blockId;
  final bool isBefore;
  final bool isEmpty;

  const _AddSlotOnOutskirts({
    required this.viewModel,
    required this.blockId,
    required this.isBefore,
    required this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return isEmpty
        ? const SizedBox.shrink()
        : Consumer<OwnerConsultationsViewmodel>(
            builder: (context, viewModel, child) {
              final bool isLoading = isBefore
                  ? viewModel.isAddingSlotBefore(blockId)
                  : viewModel.isAddingSlotAfter(blockId);

              return GestureDetector(
                onTap: isLoading
                    ? null
                    : () async {
                        if (isBefore) {
                          await viewModel.addSlotBeforeBlock(blockId);
                        } else {
                          await viewModel.addSlotAfterBlock(blockId);
                        }
                      },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: isLoading
                      ? SpinKitPouringHourGlass(
                          color: constants.primary,
                          size: constants.fsHeadline,
                        )
                      : svgs.icon(
                          'plus',
                          constants.darkGrey,
                          width: constants.fsHeadline,
                        ),
                ),
              );
            },
          );
  }
}

class _AddBlockButton extends StatelessWidget {
  final OwnerConsultationsViewmodel viewModel;

  const _AddBlockButton({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return (viewModel.noRoomsFound || viewModel.selectedRoomId == null)
        ? const SizedBox.shrink()
        : GestureDetector(
            onTap: () => nav.toCreateBlock(
              roomId: viewModel.safeSelectedRoomId!,
              onSuccess: () => viewModel.loadRoom(),
            ),
            child: Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(8),
              decoration: constants.squircleShadow(color: constants.grey),
              child: svgs.icon('plus', constants.darkGrey),
            ),
          );
  }
}

class _SettingsDropdownButton extends StatelessWidget {
  final OwnerConsultationsViewmodel viewModel;

  const _SettingsDropdownButton({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(8),
      decoration: constants.squircleShadow(color: constants.grey),
      child: PopupMenuButton<dynamic>(
        position: PopupMenuPosition.under,
        offset: const Offset(96, 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: constants.background,
        elevation: 12,
        shadowColor: constants.darkGrey30,
        padding: EdgeInsets.all(8),
        child: svgs.icon('more', constants.darkGrey),

        itemBuilder: (context) => [
          PopupMenuItem<dynamic>(
            value: "see_all_users_joined",
            child: Text(
              'See all users joined',
              style: TextStyle(
                color: constants.darkGrey,
                fontWeight: constants.fwSemiBold,
                fontSize: constants.fsLabel,
              ),
            ),
          ),
          PopupMenuItem<dynamic>(
            value: "edit_room",
            child: Text(
              'Edit room',
              style: TextStyle(
                color: constants.darkGrey,
                fontWeight: constants.fwSemiBold,
                fontSize: constants.fsLabel,
              ),
            ),
          ),
          PopupMenuItem<dynamic>(
            value: "delete_room",
            child: Text(
              'Delete room',
              style: TextStyle(
                color: constants.darkGrey,
                fontWeight: constants.fwSemiBold,
                fontSize: constants.fsLabel,
              ),
            ),
          ),
        ],
        onSelected: (mode) async {
          if (mode != null) {
            switch (mode) {
              case "edit_room":
                int? roomId = viewModel.roomIdNumber;
                if (roomId != null) {
                  await nav.toEditRoom(roomId: roomId);
                }
                break;
              case "delete_room":
                showDialog(
                  context: context,
                  builder: (_) => _DeleteRoomDialog(viewModel: viewModel),
                );
                break;
              case "see_all_users_joined":
                int? roomId = viewModel.roomIdNumber;
                String roomName = viewModel.getRoomNameById() ?? "";
                if (roomId != null) {
                  nav.toDisplayUsersInRoom(roomId: roomId, roomName: roomName);
                }
                break;
            }
          }
        },
      ),
    );
  }
}

class _DeleteRoomDialog extends StatelessWidget {
  final OwnerConsultationsViewmodel viewModel;

  const _DeleteRoomDialog({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return AlertDialog(
          backgroundColor: constants.background,
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Delete ',
                  style: TextStyle(
                    color: constants.darkGrey,
                    fontWeight: constants.fwRegular,
                    fontSize: constants.fsBody,
                  ),
                ),
                TextSpan(
                  text: '${viewModel.getRoomNameById()}?',
                  style: TextStyle(
                    color: constants.darkGrey,
                    fontWeight: constants.fwSemiBold,
                    fontSize: constants.fsBody,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            viewModel.isLoading
                ? Center(
                    child: SpinKitPouringHourGlass(
                      color: constants.primary,
                      size: constants.fsHeadline,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          nav.pop();
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: constants.darkGrey),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await viewModel.deleteRoom();
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: constants.squircleShadow(
                            color: constants.primary,
                          ),
                          child: Text(
                            "Delete",
                            style: TextStyle(color: constants.background),
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
        );
      },
    );
  }
}

class _ShowHistoryButton extends StatelessWidget {
  final VoidCallback onHistoryClicked;
  final Color color;

  const _ShowHistoryButton({
    required this.onHistoryClicked,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onHistoryClicked,
      child: svgs.icon('history', color, width: constants.fsTitle),
    );
  }
}

class _EditBlockButton extends StatelessWidget {
  final int blockId;
  final OwnerConsultationsViewmodel viewModel;

  const _EditBlockButton({required this.blockId, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => nav.toEditBlock(
        roomId: viewModel.safeSelectedRoomId!,
        blockId: blockId.toString(),
        onSuccess: () => viewModel.loadRoom(),
      ),
      child: svgs.icon("edit", constants.darkGrey, width: constants.fsTitle),
    );
  }
}
