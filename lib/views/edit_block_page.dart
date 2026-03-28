import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/create_block_viewmodel.dart';
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
      create: (_) => CreateBlockViewmodel(),
      child: Consumer<CreateBlockViewmodel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBarMenu(),
            drawer: SliderMenu(),
            backgroundColor: constants.background,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Center(child: Text(widget.blockId)),
              ),
            ),
          );
        },
      ),
    );
  }
}
