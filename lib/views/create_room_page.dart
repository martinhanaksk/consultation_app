// create_room_page.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Form for creating a new consultation room.
// Delegates the form UI to RoomFormBody, which is shared with EditRoomPage.
// Simplified to StatelessWidget since there is no data to load on init.

import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/create_room_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/room_form_body_widget.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateRoom extends StatelessWidget {
  const CreateRoom({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateRoomViewmodel(),
      child: Consumer<CreateRoomViewmodel>(
        builder: (context, viewModel, _) => Scaffold(
          appBar: AppBarMenu(),
          drawer: SliderMenu(),
          backgroundColor: constants.background,
          body: SafeArea(
            child: RoomFormBody(
              pageTitle: 'Create Room',
              viewModel: viewModel,
              isSubmitting: viewModel.isLoading,
              submitLabel: 'Create',
              onSubmit: () {
                FocusScope.of(context).unfocus();
                viewModel.createRoom(
                  helpers.trimText(viewModel.linkController.text.trim()),
                  helpers.trimText(viewModel.titleController.text.trim()),
                  helpers.trimText(viewModel.descriptionController.text.trim()),
                  int.parse(
                    helpers.trimText(
                      viewModel.cancellationHoursController.text.trim(),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
