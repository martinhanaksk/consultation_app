import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:consultation_app/models/slot_model.dart';
import 'package:consultation_app/utils/constants.dart';
import 'package:consultation_app/utils/helper_functions.dart';
import 'package:consultation_app/viewmodels/consultations_viewmodel.dart';
import 'package:consultation_app/viewmodels/slot_viewmodel.dart';

class SlotWidget extends StatefulWidget {
  final String userEmail;
  final SlotModel slot;
  final Constants constants;
  final HelperFunctions helperFunctions;
  final ConsultationsViewmodel consultationsViewmodel;
  final SlotViewmodel slotViewmodel;
  final String token;
  final String roomId;
  final BuildContext context;
  final VoidCallback loadData;

  const SlotWidget({
    super.key,
    required this.userEmail,
    required this.slot,
    required this.constants,
    required this.helperFunctions,
    required this.consultationsViewmodel,
    required this.slotViewmodel,
    required this.token,
    required this.roomId,
    required this.context,
    required this.loadData,
  });

  @override
  State<SlotWidget> createState() => _SlotWidgetState();
}

final HelperFunctions _helperFunctions = HelperFunctions();

class _SlotWidgetState extends State<SlotWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.slot.takenBy == null)
          Container(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            width: 350,
            decoration: BoxDecoration(color: widget.constants.defaultLightGrey),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.slot.startTime.split(":")[0] +
                          ":" +
                          widget.slot.startTime.split(":")[1],

                      style: TextStyle(
                        color: widget.constants.defaultDarkGrey,
                        fontSize: widget.constants.fontSizeSmall,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),

                        padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                        child: Text("Take"),
                      ),
                      onTap: () async {
                        await widget.slotViewmodel.showNoteDialog(
                          context,
                          widget.token,
                          widget.slot.id,
                        );
                        widget.loadData();
                      },
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
                    color: widget.constants.defaultWhite,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.slot.startTime.split(":")[0] +
                                ":" +
                                widget.slot.startTime.split(":")[1] +
                                " ${_helperFunctions.cropText(widget.slot.takenByName!)}",
                            style: TextStyle(
                              color: widget.constants.defaultDarkGrey,
                              fontSize: widget.constants.fontSizeSmall,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                widget.slot.note ?? '',
                                style: TextStyle(
                                  color: widget.constants.defaultDarkGrey,
                                  fontSize: widget.constants.fontSizeSmall,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(width: 10),
                              GestureDetector(
                                onTap: () async {
                                  await widget.slotViewmodel.releaseSlot(
                                    widget.token,
                                    widget.slot.id,
                                  );
                                  widget.loadData();
                                },
                                child: SvgPicture.asset('assets/images/x.svg'),
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
                    color: widget.constants.defaultWhite,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.slot.startTime.split(":")[0] +
                                ":" +
                                widget.slot.startTime.split(":")[1] +
                                " ${_helperFunctions.cropText(widget.slot.takenByName!)}",
                            style: TextStyle(
                              color: widget.constants.defaultDarkGrey,
                              fontSize: widget.constants.fontSizeSmall,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                widget.slot.note ?? '',
                                style: TextStyle(
                                  color: widget.constants.defaultDarkGrey,
                                  fontSize: widget.constants.fontSizeSmall,
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
  }
}
