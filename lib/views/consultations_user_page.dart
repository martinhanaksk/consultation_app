import 'package:consultation_app/models/slot_model.dart';
import 'package:consultation_app/utils/constants.dart';
import 'package:consultation_app/utils/helper_functions.dart';
import 'package:consultation_app/viewmodels/consultations_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/right_slider_menu.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ConsultationsUserPage extends StatefulWidget {
  final String token;
  const ConsultationsUserPage({super.key, required this.token});

  @override
  State<ConsultationsUserPage> createState() => _ConsultationsUserPageState();
}

class _ConsultationsUserPageState extends State<ConsultationsUserPage> {
  final TextEditingController emailController = TextEditingController();
  final Constants _constants = Constants();
  HelperFunctions helperFunctions = HelperFunctions();
  final ConsultationsViewmodel _consultationsViewmodel =
      ConsultationsViewmodel();
  int roomId = 0;
  Map<int, List<SlotModel?>?> slotsInBlocks = {};
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // TODO
  void _loadData() async {
    await _consultationsViewmodel.fetchData(widget.token, roomId);
    slotsInBlocks = _consultationsViewmodel.slotsInBlocks;
    setState(() {
      slotsInBlocks = _consultationsViewmodel.slotsInBlocks;
      roomId = 2;
      // slots = _consultationsViewmodel.slots;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarMenu(),
      drawer: RightSliderMenu(),
      backgroundColor: _constants.bgLight,
      body: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 80),
            Center(
              child: Text(
                "Write your self here",
                style: TextStyle(
                  color: _constants.defaultDarkGrey,
                  fontSize: _constants.fontSizeBig,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 80),

            Expanded(
              child: ListView(
                children: slotsInBlocks.entries.map((block) {
                  return Column(
                    children: [
                      Text(
                        _consultationsViewmodel.getDateOfBlock(block.key),
                        style: TextStyle(
                          color: _constants.defaultDarkGrey,
                          fontSize: _constants.fontSizeSmall,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      block.value!.isEmpty
                          ? Text("No slots found")
                          : Column(
                              children: block.value!
                                  .map(
                                    (slot) => slot == null
                                        ? Text("No slots for the block found.")
                                        : Column(
                                            children: [
                                              if (slot.takenBy == null)
                                                Container(
                                                  padding: EdgeInsets.fromLTRB(
                                                    10,
                                                    5,
                                                    10,
                                                    5,
                                                  ),
                                                  width: 350,
                                                  decoration: BoxDecoration(
                                                    color: _constants
                                                        .defaultLightGrey,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            helperFunctions
                                                                .getTimeOnlySimple(
                                                                  slot.datetime,
                                                                ),
                                                            style: TextStyle(
                                                              color: _constants
                                                                  .defaultDarkGrey,
                                                              fontSize: _constants
                                                                  .fontSizeSmall,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                            ),
                                                          ),

                                                          GestureDetector(
                                                            child: Container(
                                                              color: _constants
                                                                  .defaultWhite,
                                                              padding:
                                                                  EdgeInsets.fromLTRB(
                                                                    20,
                                                                    5,
                                                                    20,
                                                                    5,
                                                                  ),
                                                              child: Text(
                                                                "Book",
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              if (slot.takenBy != null)
                                                Container(
                                                  padding: EdgeInsets.fromLTRB(
                                                    10,
                                                    5,
                                                    10,
                                                    5,
                                                  ),
                                                  width: 350,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        _constants.defaultWhite,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            "${helperFunctions.getTimeOnlySimple(slot.datetime)}  ${_consultationsViewmodel.getUserByEmail(slot.takenBy!)!.name} ${_consultationsViewmodel.getUserByEmail(slot.takenBy!)!.surname}",
                                                            style: TextStyle(
                                                              color: _constants
                                                                  .defaultDarkGrey,
                                                              fontSize: _constants
                                                                  .fontSizeSmall,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                            ),
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                slot.note,
                                                                style: TextStyle(
                                                                  color: _constants
                                                                      .defaultDarkGrey,
                                                                  fontSize:
                                                                      _constants
                                                                          .fontSizeSmall,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
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
                                          ),
                                  )
                                  .toList(),
                            ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
