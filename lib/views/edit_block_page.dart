import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/edit_block_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

class EditBlock extends StatefulWidget {
  final String token;
  final String roomId;
  final String blockId;
  final VoidCallback? onSuccess;
  const EditBlock({
    super.key,
    required this.token,
    required this.roomId,
    required this.blockId,
    required this.onSuccess,
  });

  @override
  State<EditBlock> createState() => _EditBlockState();
}

class _EditBlockState extends State<EditBlock> {
  late final EditBlockViewmodel _viewModel;
  @override
  void initState() {
    super.initState();
    _viewModel = EditBlockViewmodel();
    _viewModel.init(widget.token, widget.blockId, widget.roomId);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<EditBlockViewmodel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBarMenu(),
            drawer: SliderMenu(),
            backgroundColor: constants.background,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          'Edit block',
                          style: TextStyle(
                            fontSize: constants.fsHeadline,
                            fontWeight: constants.fwSemiBold,
                            color: constants.darkGrey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: constants.primary.withAlpha(
                                    30,
                                  ),
                                  fixedSize: const Size(140, 120),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: constants.background,
                                    ),
                                  ),
                                  elevation: 0,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.copy,
                                      color: constants.primary,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "Copy Block",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: constants.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              ElevatedButton(
                                onPressed: () {
                                  viewModel.deleteBlock(
                                    widget.token,
                                    widget.blockId,
                                  );
                                  widget.onSuccess!();
                                  nav.pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: constants.red.withAlpha(30),
                                  fixedSize: const Size(140, 120),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: constants.background,
                                    ),
                                  ),
                                  elevation: 0,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.delete_outline_rounded,
                                      color: constants.red,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "Delete Block",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: constants.red,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),

                              Center(
                                child: Container(
                                  clipBehavior: Clip.hardEdge,
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  decoration: constants.squircleShadow(
                                    border: Border.all(
                                      color: constants.grey,
                                      width: 0.2,
                                    ),
                                    color: constants.background,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Block header row
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          20,
                                          10,
                                          20,
                                          10,
                                        ),
                                        child: Text(
                                          viewModel.getBlockDate(),
                                          style: TextStyle(
                                            color: constants.darkGrey,
                                            fontSize: constants.fsLabel,
                                            fontWeight: constants.fwSemiBold,
                                          ),
                                        ),
                                      ),

                                      const Divider(height: 1),

                                      // Slot list
                                      viewModel.isLoading
                                          ? const Padding(
                                              padding: EdgeInsets.all(24),
                                              child:
                                                  CircularProgressIndicator(),
                                            )
                                          : viewModel.slots.isEmpty
                                          ? Padding(
                                              padding: const EdgeInsets.all(24),
                                              child: Text(
                                                "No slots in this block.",
                                                style: TextStyle(
                                                  color: constants.darkGrey,
                                                  fontSize: constants.fsLabel,
                                                ),
                                              ),
                                            )
                                          : ListView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              padding: EdgeInsets.zero,
                                              itemCount: viewModel.slots.length,
                                              itemBuilder: (context, index) {
                                                final slot =
                                                    viewModel.slots[index];
                                                return _SlotDeleteRow(
                                                  label: slot.startTime,
                                                  isFirst: index == 0,
                                                  isLast:
                                                      index ==
                                                      viewModel.slots.length -
                                                          1,
                                                  onDelete: () =>
                                                      viewModel.deleteSlot(
                                                        widget.token,
                                                        slot.id,
                                                      ),
                                                );
                                              },
                                            ),
                                    ],
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
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SlotDeleteRow extends StatelessWidget {
  final String label;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onDelete;

  const _SlotDeleteRow({
    required this.label,
    required this.isFirst,
    required this.isLast,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!isFirst) Divider(height: 1, color: constants.grey),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: constants.darkGrey,
                  fontSize: constants.fsLabel,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: onDelete,
                  child: Icon(Icons.delete, color: constants.red, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
