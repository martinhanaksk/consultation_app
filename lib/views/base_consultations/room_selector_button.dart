import 'package:flutter/material.dart';
import 'package:consultation_app/models/room_model.dart';
import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/base_consultations_viewmodel.dart';

class RoomSelectorButton extends StatelessWidget {
  final BaseConsultationsViewmodel viewModel;

  const RoomSelectorButton({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final bool noRoom = viewModel.noRoomsFound || viewModel.selectedRoomId == null;
    final Color labelColor = noRoom
        ? constants.darkGrey100
        : viewModel.isLoading
            ? constants.primary
            : constants.darkGrey;

    return Transform.translate(
      offset: const Offset(0, -1),
      child: Container(
        decoration: BoxDecoration(color: constants.background),
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Center(
          child: Column(
            children: [
              PopupMenuButton<String>(
                position: PopupMenuPosition.under,
                offset: const Offset(0, 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: constants.background,
                elevation: 12,
                shadowColor: constants.darkGrey30,
                onSelected: (String newValue) async {
                  final success = await viewModel.validateAndSelectRoom(
                    int.parse(newValue),
                  );
                  if (success) await viewModel.switchRoom(int.parse(newValue));
                },
                itemBuilder: (context) => viewModel.rooms == null
                    ? []
                    : viewModel.rooms!.map((RoomModel value) {
                        final isSelected =
                            value.id == viewModel.safeSelectedRoomId;
                        return PopupMenuItem<String>(
                          value: value.id.toString(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 4,
                          ),
                          child: Text(
                            value.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? constants.fwSemiBold
                                  : constants.fwRegular,
                              color: isSelected
                                  ? constants.primary
                                  : constants.darkGrey,
                            ),
                          ),
                        );
                      }).toList(),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.8,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: constants.squircleShadow(color: constants.grey),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          viewModel.isLoading
                              ? "Loading..."
                              : noRoom
                                  ? "No rooms created"
                                  : '${viewModel.selectedRoom?.title} - ${viewModel.selectedRoom?.description}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: constants.fwSemiBold,
                            color: labelColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      svgs.icon('arrow_down', labelColor, width: constants.fsBody),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
