import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/create_room_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/custom_text_field_widget.dart';
import 'package:consultation_app/views/custom_widgets/slider_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

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
                      CustomInputTextField(
                        controller: viewModel.titleController,
                        hintText: "Title (e.g. Martin's room)",
                      ),

                      const SizedBox(height: 16),
                      CustomInputTextField(
                        controller: viewModel.shortNameController,
                        hintText: "https://example.com",
                        isUrl: true,
                        maxLength: 2000,
                      ),

                      const SizedBox(height: 16),
                      CustomInputTextField(
                        controller: viewModel.descriptionController,
                        hintText: 'Description (e.g. D105)',
                      ),

                      const SizedBox(height: 16),
                      CustomInputTextField(
                        controller: viewModel.cancellationHoursController,
                        hintText: 'Cancel deadline in hours',
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                      ),

                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          "Allowed email domains",
                          style: TextStyle(
                            fontSize: constants.fsLabel,
                            color: constants.darkGrey100,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),

                      TextField(
                        maxLength: 50,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r"[a-zA-Z0-9@._\-+]"),
                          ),
                        ],
                        style: TextStyle(color: constants.darkGrey),
                        controller: viewModel.acceptedEmailController,
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
                                constants.primary,
                                width: constants.fsBody,
                              ),
                            ),
                            onTap: () {
                              if (validator.validateNotEmpty(
                                viewModel.acceptedEmailController.text.trim(),
                                context,
                              )) {
                                viewModel.addToAcceptedEmails(
                                  helpers.trimText(
                                    viewModel.acceptedEmailController.text
                                        .trim(),
                                  ),
                                );
                                viewModel.acceptedEmailController.clear();
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
                                        viewModel.shortNameController.text
                                            .trim(),
                                        context,
                                      ) &&
                                      validator.validateNotEmpty(
                                        viewModel.titleController.text.trim(),
                                        context,
                                      ) &&
                                      validator.validateNotEmpty(
                                        viewModel.descriptionController.text
                                            .trim(),
                                        context,
                                      ) &&
                                      validator.validateNotEmpty(
                                        viewModel
                                            .cancellationHoursController
                                            .text
                                            .trim(),
                                        context,
                                      )) {
                                    viewModel.createRoom(
                                      helpers.trimText(
                                        viewModel.shortNameController.text
                                            .trim(),
                                      ),
                                      helpers.trimText(
                                        viewModel.titleController.text.trim(),
                                      ),
                                      helpers.trimText(
                                        viewModel.descriptionController.text
                                            .trim(),
                                      ),
                                      int.parse(
                                        helpers.trimText(
                                          viewModel
                                              .cancellationHoursController
                                              .text
                                              .trim(),
                                        ),
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
