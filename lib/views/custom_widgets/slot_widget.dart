import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:consultation_app/models/slot_model.dart';
import 'package:consultation_app/viewmodels/slot_viewmodel.dart';
import 'package:consultation_app/setup.dart';
import 'package:provider/provider.dart';

class SlotWidget extends StatefulWidget {
  final String userEmail;
  final SlotModel slot;
  final String token;
  final String roomId;
  final BuildContext context;
  final bool isFirst;
  final bool isLast;
  final VoidCallback loadData;

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
  });

  @override
  State<SlotWidget> createState() => _SlotWidgetState();
}

class _SlotWidgetState extends State<SlotWidget> {
  Future<void> _showNoteDialog(
    BuildContext context,
    SlotViewmodel viewModel,
  ) async {
    final TextEditingController controller = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true, // allows the sheet to resize with keyboard
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(
              context,
            ).viewInsets.bottom, // shifts up with keyboard
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Title
                const Text(
                  "Add a visit purpose",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),

                // Input field
                TextField(
                  controller: controller,
                  autofocus: true,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: "Write something...",
                    filled: true,
                    fillColor: Colors.grey[100],
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
                const SizedBox(height: 20),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey[300]!),
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
                        child: const Text(
                          "Submit",
                          style: TextStyle(color: Colors.white),
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
                      color: constants.white,
                      border: Border.all(color: Color(0xFFCBCBCB), width: 0.2),
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

                                style: TextStyle(
                                  color: constants.darkGrey,
                                  fontSize: constants.fontSizeSmall,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  onTap: () => _showNoteDialog(context, viewModel),
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
                          border: Border.all(
                            color: Color(0xFFCBCBCB),
                            width: 0.2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 55,

                                      child: Text(
                                        '${widget.slot.startTime.split(":")[0]}${":"}${widget.slot.startTime.split(":")[1]}',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          color: constants.darkWhite,
                                          fontSize: constants.fontSizeSmall,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 10),
                                    Text(
                                      helpers.cropText(
                                        widget.slot.takenByName ?? '',
                                      ),
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        color: constants.darkWhite,
                                        fontSize: constants.fontSizeSmall,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),

                                Row(
                                  children: [
                                    Text(
                                      widget.slot.note ?? '',
                                      style: TextStyle(
                                        color: constants.darkWhite,
                                        fontSize: constants.fontSizeSmall,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: () async {
                                        await viewModel.releaseSlot(
                                          widget.token,
                                          widget.slot.id,
                                        );
                                        widget.loadData();
                                      },
                                      child: SvgPicture.asset(
                                        'assets/resources/x.svg',
                                      ),
                                    ),
                                  ],
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
                          color: constants.lightRed,
                          border: Border.all(
                            color: Color(0xFFCBCBCB),
                            width: 0.2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 55,
                                      child: Text(
                                        '${widget.slot.startTime.split(":")[0]}${":"}${widget.slot.startTime.split(":")[1]}',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          color: constants.grey,
                                          fontSize: constants.fontSizeSmall,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      width: 150,
                                      child: Text(
                                        helpers.cropText(
                                          widget.slot.takenByName!,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: constants.grey,
                                          fontSize: constants.fontSizeSmall,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                Row(
                                  children: [
                                    SizedBox(
                                      width: 40,
                                      child: Text(
                                        widget.slot.note ?? '',
                                        style: TextStyle(
                                          color: constants.grey,
                                          fontSize: constants.fontSizeSmall,
                                          fontWeight: FontWeight.w400,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),

                                    SizedBox(width: 10),
                                    SizedBox(
                                      width: 20,
                                      child: GestureDetector(
                                        onTap: () {
                                          viewModel.handleEmailSubscribe(
                                            widget.token,
                                            widget.slot.blockId,
                                          );
                                          if (viewModel.temporaryBellBoolean) {
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
                                            ? Image.asset(
                                                'assets/resources/bell-ringing.png',
                                                width: 20,
                                              )
                                            : Image.asset(
                                                'assets/resources/bell-empty.png',
                                                width: 20,
                                              ),
                                      ),
                                    ),
                                  ],
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
