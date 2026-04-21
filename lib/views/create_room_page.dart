import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/create_room_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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

  final TextEditingController roomNameController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController acceptedEmailController = TextEditingController();
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
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Create Room',
                          style: TextStyle(
                            fontSize: constants.fsHeadline,
                            fontWeight: constants.fwSemiBold,
                            color: constants.darkGrey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: constants.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: constants.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: constants.primary,
                              width: 1.5,
                            ),
                          ),
                          hintText: 'Title',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: roomNameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: constants.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: constants.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: constants.primary,
                              width: 1.5,
                            ),
                          ),
                          hintText: 'Room name',
                        ),
                      ),

                      const SizedBox(height: 16),
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: constants.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: constants.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: constants.primary,
                              width: 1.5,
                            ),
                          ),
                          hintText: 'Description',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Allowed email domains",
                        style: TextStyle(
                          fontSize: constants.fsLabel,
                          color: constants.darkGrey.withAlpha(70),
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: acceptedEmailController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: constants.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: constants.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: constants.primary,
                              width: 1.5,
                            ),
                          ),
                          suffixIcon: GestureDetector(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: svgs.icon(
                                'add',
                                width: constants.fsBody,
                                color: constants.primary,
                              ),
                            ),
                            onTap: () {
                              if (validator.validateNotEmpty(
                                acceptedEmailController.text.trim(),
                                context,
                              )) {
                                viewModel.addToAcceptedEmails(
                                  helpers.trimText(
                                    acceptedEmailController.text.trim(),
                                  ),
                                );
                                acceptedEmailController.clear();
                              }
                            },
                          ),
                          hintText: '@domain.com, user@domain.com..',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: GestureDetector(
                          onTap: () =>
                              nav.toDisplayListOfEmails(viewModel: viewModel),
                          child: Text(
                            "View added domains (${viewModel.acceptedEmails.length})",
                            style: TextStyle(
                              color: constants.primary,
                              fontSize: constants.fsLabel,
                              fontWeight: constants.fwSemiBold,
                              decoration: TextDecoration.underline,
                              decorationColor: constants.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      viewModel.isLoading
                          ? Center(
                              child: SpinKitPouringHourGlass(
                                color: constants.primary,
                                size: constants.fsHeadline,
                              ),
                            )
                          : SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () async {
                                  FocusScope.of(context).unfocus();
                                  if (validator.validateNotEmpty(
                                        roomNameController.text.trim(),
                                        context,
                                      ) &&
                                      validator.validateNotEmpty(
                                        titleController.text.trim(),
                                        context,
                                      ) &&
                                      validator.validateNotEmpty(
                                        descriptionController.text.trim(),
                                        context,
                                      )) {
                                    viewModel.createRoom(
                                      helpers.trimText(
                                        roomNameController.text.trim(),
                                      ),
                                      helpers.trimText(
                                        titleController.text.trim(),
                                      ),
                                      helpers.trimText(
                                        descriptionController.text.trim(),
                                      ),
                                    );
                                  }
                                },
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
