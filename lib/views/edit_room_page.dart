// edit_room_page.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Allows a teacher to edit an existing room's details.
// The form itself is delegated to RoomFormBody, which is shared with CreateRoomPagePage.

import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/edit_room_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/room_form_body_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class EditRoomPage extends StatefulWidget {
  final int roomId;

  const EditRoomPage({super.key, required this.roomId});

  @override
  State<EditRoomPage> createState() => _EditRoomPageState();
}

class _EditRoomPageState extends State<EditRoomPage> {
  late final EditRoomViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // Cascade initialises and immediately fetches room data in one expression
    _viewModel = EditRoomViewModel()..loadData(widget.roomId);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<EditRoomViewModel>(
        builder: (context, viewModel, _) => Scaffold(
          appBar: AppBarMenu(),
          backgroundColor: constants.background,
          body: SafeArea(
            // Three states: loading while fetching, error if room is null, or the form
            child: viewModel.isLoading
                ? Center(
                    child: SpinKitPouringHourGlass(
                      color: constants.primary,
                      size: constants.fsHeadline,
                    ),
                  )
                : viewModel.room == null
                ? Text(
                    viewModel.errorMessage ?? 'Room not found',
                    style: TextStyle(color: constants.darkGrey),
                  )
                : RoomFormBody(
                    pageTitle: 'Edit Room',
                    viewModel: viewModel,
                    isSubmitting: viewModel.isSaving,
                    submitLabel: 'Save Changes',
                    onSubmit: () {
                      FocusScope.of(context).unfocus();
                      viewModel.handleSave();
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
