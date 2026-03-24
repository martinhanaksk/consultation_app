import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/create_block_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
            body: SafeArea(child: Text("Create block ${widget.roomId}")),
          );
        },
      ),
    );
  }
}
