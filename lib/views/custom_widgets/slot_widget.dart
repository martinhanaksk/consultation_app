import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:consultation_app/models/slot_model.dart';
import 'package:consultation_app/viewmodels/slot_viewmodel.dart';
import 'package:consultation_app/setup.dart';
import 'package:provider/provider.dart';
import 'package:figma_squircle/figma_squircle.dart';

class SlotWidget extends StatefulWidget {
  final String userEmail;
  final SlotModel slot;
  final String token;
  final String roomId;
  final BuildContext context;
  final bool isFirst;
  final bool isLast;
  final VoidCallback loadData;
  final String date;

  const SlotWidget({
    super.key,
    required this.userEmail,
    required this.slot,
    required this.token,
    required this.roomId,
    required this.context,
    required this.loadData,
    required this.isFirst,
    required this.isLast,
    required this.date,
  });

  @override
  State<SlotWidget> createState() => _SlotWidgetState();
}

class _SlotWidgetState extends State<SlotWidget> {
  Future<void> _showNoteDialog(
    BuildContext context,
    SlotViewmodel viewModel,
    String startTime,
    int duration,
    String date,
  ) async {
    final TextEditingController controller = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: constants.transparent,
      builder: (context) {
        return ListenableBuilder(
          // 👈 ADD THIS WRAPPER
          listenable: viewModel,
          builder: (context, _) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: constants.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      "Add a visit purpose",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: constants.fwSemiBold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      padding: const EdgeInsets.all(20),
                      decoration: constants.figmaLightShadowWith(
                        color: constants.background,
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 20,
                          cornerSmoothing: 0.6,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    size: constants.fsLabel,
                                    color: constants.darkGrey,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Date",
                                    style: TextStyle(
                                      fontSize: constants.fsLabel,
                                      fontWeight: constants.fwRegular,
                                      color: constants.darkGrey,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                date,
                                style: TextStyle(
                                  fontSize: constants.fsLabel,
                                  fontWeight: constants.fwRegular,
                                  color: constants.darkGrey,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_outlined,
                                    size: constants.fsLabel,
                                    color: constants.darkGrey,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Time",
                                    style: TextStyle(
                                      fontSize: constants.fsLabel,
                                      fontWeight: constants.fwRegular,
                                      color: constants.darkGrey,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                startTime,
                                style: TextStyle(
                                  fontSize: constants.fsLabel,
                                  fontWeight: constants.fwRegular,
                                  color: constants.darkGrey,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.hourglass_bottom_rounded,
                                    size: constants.fsLabel,
                                    color: constants.darkGrey,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Duration",
                                    style: TextStyle(
                                      fontSize: constants.fsLabel,
                                      fontWeight: constants.fwRegular,
                                      color: constants.darkGrey,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                duration.toString(),
                                style: TextStyle(
                                  fontSize: constants.fsLabel,
                                  fontWeight: constants.fwRegular,
                                  color: constants.darkGrey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      clipBehavior: Clip.none,
                      decoration: constants.figmaLightShadowWith(
                        color: constants.background,
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 12,
                          cornerSmoothing: 0.6,
                        ),
                      ),
                      child: TextField(
                        controller: controller,
                        autofocus: true,
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintText: "Type in visit purpose...",
                          filled: true,
                          fillColor: constants.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                     Text(
                      "Meeting Type:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: constants.fwSemiBold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        // in-person
                        viewModel.isOnlineSelected
                            ? Expanded(
                                child: ElevatedButton(
                                  onPressed: () =>
                                      viewModel.setIsOnlineSelected(false),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: constants.background,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                        color: constants.background,
                                      ),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Column(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/resources/location_grey.svg',
                                      ),
                                      Text(
                                        "In-Person",
                                        style: TextStyle(
                                          color: constants.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Expanded(
                                child: ElevatedButton(
                                  onPressed: () =>
                                      viewModel.setIsOnlineSelected(false),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: constants.primary,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                        color: constants.background,
                                      ),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Column(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/resources/location.svg',
                                      ),
                                      Text(
                                        "In-Person",
                                        style: TextStyle(
                                          color: constants.background,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        const SizedBox(width: 12),
                        // Online
                        viewModel.isOnlineSelected
                            ? Expanded(
                                child: ElevatedButton(
                                  onPressed: () =>
                                      viewModel.setIsOnlineSelected(true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: constants.primary,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                        color: constants.background,
                                      ),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Column(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/resources/screen.svg',
                                      ),
                                      Text(
                                        "Online",
                                        style: TextStyle(
                                          color: constants.background,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Expanded(
                                child: ElevatedButton(
                                  onPressed: () =>
                                      viewModel.setIsOnlineSelected(true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: constants.background,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                        color: constants.background,
                                      ),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Column(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/resources/screen_grey.svg',
                                      ),
                                      Text(
                                        "Online",
                                        style: TextStyle(
                                          color: constants.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: constants.background),
                              ),
                            ),
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: constants.primary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await viewModel.takeSlot(
                                widget.token,
                                widget.slot.id,
                                controller.text.trim(),
                              );
                              widget.loadData();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: constants.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              "Submit",
                              style: TextStyle(color: constants.background),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SlotViewmodel(),
      child: Consumer<SlotViewmodel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              //free slot
              if (widget.slot.takenBy == null)
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      borderRadius: widget.isFirst
                          ? BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0),
                              bottomLeft: Radius.circular(0.0),
                              bottomRight: Radius.circular(0.0),
                            )
                          : widget.isLast
                          ? BorderRadius.only(
                              topLeft: Radius.circular(0.0),
                              topRight: Radius.circular(0.0),
                              bottomLeft: Radius.circular(20.0),
                              bottomRight: Radius.circular(20.0),
                            )
                          : BorderRadius.circular(0),
                      color: constants.background,
                      border: Border.all(color: constants.grey, width: 0.2),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 55,
                              child: Text(
                                '${widget.slot.startTime.split(":")[0]}${":"}${widget.slot.startTime.split(":")[1]}',
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: constants.darkGrey,
                                  fontSize: constants.fsLabel,
                                  fontWeight: constants.fwRegular,
                                ),
                              ),
                            ),
                            SvgPicture.asset('assets/resources/take_slot.svg'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  onTap: () => _showNoteDialog(
                    context,
                    viewModel,
                    widget.slot.startTime,
                    widget.slot.duration,
                    widget.date,
                  ),
                ),
              if (widget.slot.takenBy != null)
                //my slot
                widget.slot.takenBy == widget.userEmail
                    ? Container(
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          borderRadius: widget.isFirst
                              ? BorderRadius.only(
                                  topLeft: Radius.circular(20.0),
                                  topRight: Radius.circular(20.0),
                                  bottomLeft: Radius.circular(0.0),
                                  bottomRight: Radius.circular(0.0),
                                )
                              : widget.isLast
                              ? BorderRadius.only(
                                  topLeft: Radius.circular(0.0),
                                  topRight: Radius.circular(0.0),
                                  bottomLeft: Radius.circular(20.0),
                                  bottomRight: Radius.circular(20.0),
                                )
                              : BorderRadius.circular(0),
                          color: constants.green,
                          border: Border.all(color: constants.grey, width: 0.2),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 55,

                                      child: Text(
                                        '${widget.slot.startTime.split(":")[0]}${":"}${widget.slot.startTime.split(":")[1]}',
                                        textAlign: TextAlign.right,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: constants.background,
                                          fontSize: constants.fsLabel,
                                          fontWeight: constants.fwRegular,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      flex: 2,
                                      fit: FlexFit.loose,
                                      child: Text(
                                        helpers.cropText(
                                          widget.slot.takenByName ?? '',
                                        ),
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          color: constants.background,
                                          fontSize: constants.fsLabel,
                                          fontWeight: constants.fwRegular,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                ),
                                Flexible(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Flexible(
                                        flex: 2,
                                        fit: FlexFit.loose,
                                        child: Text(
                                          widget.slot.note ?? '',
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: constants.background,
                                            fontSize: constants.fsLabel,
                                            fontWeight: constants.fwRegular,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      widget.slot.isOnline == 1
                                          ? SvgPicture.asset(
                                              'assets/resources/screen.svg',
                                            )
                                          : SvgPicture.asset(
                                              'assets/resources/location.svg',
                                            ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () async {
                                          await viewModel.releaseSlot(
                                            widget.token,
                                            widget.slot.id,
                                          );
                                          widget.loadData();
                                        },
                                        child: SvgPicture.asset(
                                          'assets/resources/cross.svg',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    //someone's slot
                    : Container(
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          borderRadius: widget.isFirst
                              ? BorderRadius.only(
                                  topLeft: Radius.circular(20.0),
                                  topRight: Radius.circular(20.0),
                                  bottomLeft: Radius.circular(0.0),
                                  bottomRight: Radius.circular(0.0),
                                )
                              : widget.isLast
                              ? BorderRadius.only(
                                  topLeft: Radius.circular(0.0),
                                  topRight: Radius.circular(0.0),
                                  bottomLeft: Radius.circular(20.0),
                                  bottomRight: Radius.circular(20.0),
                                )
                              : BorderRadius.circular(0),
                          color: constants.red,
                          border: Border.all(color: constants.grey, width: 0.2),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 55,

                                      child: Text(
                                        '${widget.slot.startTime.split(":")[0]}${":"}${widget.slot.startTime.split(":")[1]}',
                                        textAlign: TextAlign.right,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: constants.background,
                                          fontSize: constants.fsLabel,
                                          fontWeight: constants.fwRegular,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      flex: 2,
                                      fit: FlexFit.loose,
                                      child: Text(
                                        helpers.cropText(
                                          widget.slot.takenByName ?? '',
                                        ),
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          color: constants.background,
                                          fontSize: constants.fsLabel,
                                          fontWeight: constants.fwRegular,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                ),
                                Flexible(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Flexible(
                                        flex: 2,
                                        fit: FlexFit.loose,
                                        child: Text(
                                          widget.slot.note ?? '',
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: constants.background,
                                            fontSize: constants.fsLabel,
                                            fontWeight: constants.fwRegular,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      widget.slot.isOnline == 1
                                          ? SvgPicture.asset(
                                              'assets/resources/screen.svg',
                                            )
                                          : SvgPicture.asset(
                                              'assets/resources/location.svg',
                                            ),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 20,
                                        child: GestureDetector(
                                          onTap: () {
                                            // viewModel.handleEmailSubscribe(
                                            //   widget.token,
                                            //   widget.slot.blockId,
                                            // );
                                            viewModel.setTemporarybellboolean(
                                              !viewModel.temporaryBellBoolean,
                                            );
                                            if (viewModel
                                                .temporaryBellBoolean) {
                                              notify.showToast(
                                                "Notifications enabled for selected slot",
                                              );
                                            } else {
                                              notify.showToast(
                                                "Notifications disabled for selected slot",
                                              );
                                            }
                                          },
                                          child: viewModel.temporaryBellBoolean
                                              ? SvgPicture.asset(
                                                  'assets/resources/notifications_bell_on.svg',
                                                )
                                              : SvgPicture.asset(
                                                  'assets/resources/notifications_bell_off.svg',
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
            ],
          );
        },
      ),
    );
  }
}
