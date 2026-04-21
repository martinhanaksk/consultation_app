import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/edit_room_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class EditRoomPage extends StatefulWidget {
  final String token;
  final int roomId;

  const EditRoomPage({
    Key? key,
    required this.token,
    required this.roomId,
  }) : super(key: key);

  @override
  State<EditRoomPage> createState() => _EditRoomPageState();
}

class _EditRoomPageState extends State<EditRoomPage> {
  late final EditRoomViewmodel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = EditRoomViewmodel();
    // Fetch data as soon as the view model initializes
    _viewModel.loadData(widget.token, widget.roomId);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    _viewModel.clearError();
    bool success = await _viewModel.submitChanges(widget.token);
    
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room updated successfully')),
      );
      Navigator.pop(context, true);
    } else if (_viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_viewModel.errorMessage!)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update room')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<EditRoomViewmodel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: constants.background,
              elevation: 0,
              iconTheme: IconThemeData(color: constants.darkGrey),
            ),
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
                      ? Center(
                          child: Text(
                            viewModel.errorMessage ?? 'Room not found',
                            style: TextStyle(color: constants.darkGrey),
                          ),
                        )
                      : SingleChildScrollView(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                children: [
                                  Text(
                                    'Edit Room',
                                    style: TextStyle(
                                      color: constants.darkGrey,
                                      fontWeight: constants.fwSemiBold,
                                      fontSize: constants.fsHeadline,
                                    ),
                                  ),
                                  const SizedBox(height: 30),

                                  // Short Name Input
                                  _buildInputBox(
                                    controller: viewModel.shortNameController,
                                    hintText: 'Short Name (e.g. TestRm)',
                                  ),
                                  const SizedBox(height: 20),

                                  // Room Title Input
                                  _buildInputBox(
                                    controller: viewModel.titleController,
                                    hintText: 'Room Title (e.g. Main test room)',
                                  ),
                                  const SizedBox(height: 20),

                                  // Description Input
                                  _buildInputBox(
                                    controller: viewModel.descriptionController,
                                    hintText: 'Description',
                                    maxLines: 3,
                                  ),
                                  const SizedBox(height: 20),

                                  // Accepted Emails Input
                                  _buildInputBox(
                                    controller: viewModel.acceptedEmailsController,
                                    hintText: 'Accepted Emails/Domains (comma separated)',
                                  ),
                                  const SizedBox(height: 40),

                                  // Save Button
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
                                            onPressed: _handleSave,
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
            ),
          );
        },
      ),
    );
  }

  // Reusable widget builder for the styled squircle inputs
  Widget _buildInputBox({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return Container(
      clipBehavior: Clip.none,
      decoration: constants.squircleShadow(
        color: constants.background,
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: constants.fsBody,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
