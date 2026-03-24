import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/create_block_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class CreateBlock extends StatefulWidget {
  final String token;
  final String roomId;
  const CreateBlock({super.key, required this.token, required this.roomId});

  @override
  State<CreateBlock> createState() => _CreateBlockState();
}

class _CreateBlockState extends State<CreateBlock> {
  @override
  void initState() {
    super.initState();
  }

  final TextEditingController noteController = TextEditingController();
  String _selectedDate = '';
  String _dateCount = '';
  String _range = '';
  String _rangeCount = '';
  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    /// The argument value will return the changed date as [DateTime] when the
    /// widget [SfDateRangeSelectionMode] set as single.
    ///
    /// The argument value will return the changed dates as [List<DateTime>]
    /// when the widget [SfDateRangeSelectionMode] set as multiple.
    ///
    /// The argument value will return the changed range as [PickerDateRange]
    /// when the widget [SfDateRangeSelectionMode] set as range.
    ///
    /// The argument value will return the changed ranges as
    /// [List<PickerDateRange] when the widget [SfDateRangeSelectionMode] set as
    /// multi range.
    setState(() {
      if (args.value is PickerDateRange) {
        _range =
            '${DateFormat('dd/MM/yyyy').format(args.value.startDate)} -'
            // ignore: lines_longer_than_80_chars
            ' ${DateFormat('dd/MM/yyyy').format(args.value.endDate ?? args.value.startDate)}';
      } else if (args.value is DateTime) {
        _selectedDate = args.value.toString();
      } else if (args.value is List<DateTime>) {
        _dateCount = args.value.length.toString();
      } else {
        _rangeCount = args.value.length.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateBlockViewmodel(),
      child: Consumer<CreateBlockViewmodel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBarMenu(),
            drawer: SliderMenu(),
            backgroundColor: constants.background,
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        child: Text("Select dates"),
                        onTap: () {
                          notify.showToast("Select dates");
                        },
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        child: Text("Start time"),
                        onTap: () {
                          notify.showToast("Start time");
                        },
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        child: Text("Duration"),
                        onTap: () {
                          notify.showToast("Duration");
                        },
                      ),
                      SizedBox(height: 20),
                      Container(
                      clipBehavior: Clip.none,
                      decoration: constants.squircleShadow(
                        color: constants.background,
                       
                      ),
                      child:  TextField(
                          scrollPadding: EdgeInsets.only(bottom: 1000),
                          controller: noteController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                        
                            hintText: 'Note',
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => {notify.showToast("Created")},dec
                          style: ElevatedButton.styleFrom(
                            backgroundColor: constants.primary,
                            disabledBackgroundColor: constants.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 2,
                            shadowColor: constants.primary,
                          ),
                          child: Text(
                            'Create',
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
              ),
            ),
          );
        },
      ),
    );
  }
}
