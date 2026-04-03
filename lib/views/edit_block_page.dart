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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditBlockViewmodel(),
      child: Consumer<EditBlockViewmodel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBarMenu(),
            drawer: SliderMenu(),
            backgroundColor: constants.background,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),

                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          'Edit block',
                          style: TextStyle(
                            fontSize: constants.fsHeadline,
                            fontWeight: constants.fwSemiBold,
                            color: constants.darkGrey,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            child: Icon(Icons.delete, color: constants.red),
                            onTap: () {
                              viewModel.deleteBlock(
                                widget.token,
                                int.parse(widget.blockId),
                              );
                              widget.onSuccess?.call();
                              nav.pop();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      child: Center(
                        child: Text("Editing block number " + widget.blockId),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
