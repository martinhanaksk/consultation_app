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
  final VoidCallback loadData;

  const SlotWidget({
    super.key,
    required this.userEmail,
    required this.slot,
    required this.token,
    required this.roomId,
    required this.context,
    required this.loadData,
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
                          style: TextStyle(color: constants.primaryColor),
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
                          backgroundColor: constants.primaryColor,
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
              if (widget.slot.takenBy == null)
                Container(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  width: 350,
                  decoration: BoxDecoration(color: constants.defaultLightGrey),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${widget.slot.startTime.split(":")[0]}${":"}${widget.slot.startTime.split(":")[1]}',

                            style: TextStyle(
                              color: constants.defaultDarkGrey,
                              fontSize: constants.fontSizeSmall,
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          GestureDetector(
                            child: Container(
                              decoration: BoxDecoration(
                                color: constants.bgLight,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(6),
                                ),
                              ),

                              padding: EdgeInsets.fromLTRB(8, 5, 8, 5),
                            ),
                            onTap: () => _showNoteDialog(context, viewModel),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              if (widget.slot.takenBy != null)
                widget.slot.takenBy == widget.userEmail
                    ? Container(
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        width: 350,
                        decoration: BoxDecoration(
                          color: constants.defaultWhite,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${widget.slot.startTime.split(":")[0]}${":"}${widget.slot.startTime.split(":")[1]} ${helpers.cropText(widget.slot.takenByName ?? '')}',
                                  style: TextStyle(
                                    color: constants.defaultDarkGrey,
                                    fontSize: constants.fontSizeSmall,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      widget.slot.note ?? '',
                                      style: TextStyle(
                                        color: constants.defaultDarkGrey,
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
                                        'assets/images/x.svg',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : Container(
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        width: 350,
                        decoration: BoxDecoration(
                          color: constants.defaultWhite,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${widget.slot.startTime.split(":")[0]}${":"}${widget.slot.startTime.split(":")[1]} ${{helpers.cropText(widget.slot.takenByName!)}}',
                                  style: TextStyle(
                                    color: constants.defaultDarkGrey,
                                    fontSize: constants.fontSizeSmall,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      widget.slot.note ?? '',
                                      style: TextStyle(
                                        color: constants.defaultDarkGrey,
                                        fontSize: constants.fontSizeSmall,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: () {},
                                      child: SvgPicture.asset(
                                        'assets/images/watchdog-green.svg',
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
