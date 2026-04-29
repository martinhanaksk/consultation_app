import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/edit_room_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class EditRoomPage extends StatefulWidget {
  final String token;
  final int roomId;

  const EditRoomPage({super.key, required this.token, required this.roomId});

  @override
  State<EditRoomPage> createState() => _EditRoomPageState();
}

class _EditRoomPageState extends State<EditRoomPage> {
  late final EditRoomViewmodel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = EditRoomViewmodel();
    _viewModel.loadData(widget.token, widget.roomId);
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
      child: Consumer<EditRoomViewmodel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBarMenu(),
            backgroundColor: constants.background,
            body: SafeArea(
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
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                'Edit Room',
                                style: TextStyle(
                                  color: constants.darkGrey,
                                  fontWeight: constants.fwSemiBold,
                                  fontSize: constants.fsHeadline,
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Short Name Input
                            _inputBox(
                              controller: viewModel.shortNameController,
                              hintText: 'Short Name (e.g. TestRm)',
                            ),
                            const SizedBox(height: 20),

                            // Room Title Input
                            _inputBox(
                              controller: viewModel.titleController,
                              hintText: 'Room Title (e.g. Main test room)',
                            ),
                            const SizedBox(height: 20),

                            // Description Input
                            _inputBox(
                              controller: viewModel.descriptionController,
                              hintText: 'Description',
                              maxLines: 3,
                            ),
                            const SizedBox(height: 20),
                            _inputBox(
                              controller: viewModel.cancellationHoursController,
                              hintText: 'Cancel deadline (hrs)',
                              maxLines: 1,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 20),

                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                "Allowed email domains",
                                style: TextStyle(
                                  fontSize: constants.fsLabel,
                                  color: constants.darkGrey150,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextField(
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
                                      viewModel.acceptedEmailController.text
                                          .trim(),
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
                                onTap: () => nav.toDisplayListOfEmails(
                                  viewModel: viewModel,
                                ),
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

                            viewModel.isSaving
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
                                      onPressed: () async => {
                                        await viewModel.handleSave(
                                          widget.token,
                                        ),
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: constants.primary,
                                        disabledBackgroundColor:
                                            constants.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        elevation: 2,
                                        shadowColor: constants.primary,
                                      ),
                                      child: Text(
                                        'Save Changes',
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

  Widget _inputBox({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      clipBehavior: Clip.none,
      decoration: constants.squircleShadow(color: constants.background),
      child: TextField(
        style: TextStyle(color: constants.darkGrey),
        controller: controller,
        maxLines: maxLines,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: const OutlineInputBorder(borderSide: BorderSide.none),
          hintText: hintText,
          hintStyle: TextStyle(
            color: constants.grey,
            fontSize: constants.fsBody,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
