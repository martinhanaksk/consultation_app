import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/create_room_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateRoom extends StatefulWidget {
  const CreateRoom({super.key});

  @override
  State<CreateRoom> createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateRoomViewmodel(),
      child: Consumer<CreateRoomViewmodel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBarMenu(),
            drawer: SliderMenu(),
            backgroundColor: constants.background,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: GestureDetector(
                    child: Text("Create Room"),
                    onTap: () {
                      viewModel.createRoom();
                    },
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
