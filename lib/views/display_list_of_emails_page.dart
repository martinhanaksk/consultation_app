import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/create_room_viewmodel.dart';
import 'package:flutter/material.dart';

class DisplayListOfEmailsPage extends StatefulWidget {
  final CreateRoomViewmodel viewModel;
  const DisplayListOfEmailsPage({super.key, required this.viewModel});
  @override
  State<DisplayListOfEmailsPage> createState() =>
      _DisplayListOfEmailsPageState();
}

class _DisplayListOfEmailsPageState extends State<DisplayListOfEmailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constants.background,
      appBar: AppBar(title: Text('Allowed email domains')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            return ListView.builder(
              itemCount: widget.viewModel.acceptedEmails.length,
              itemBuilder: (context, index) => ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.viewModel.acceptedEmails[index]),
                    IconButton(
                      icon: Icon(Icons.delete, color: constants.red),
                      onPressed: () =>
                          widget.viewModel.removeFromAcceptedEmails(
                            widget.viewModel.acceptedEmails[index],
                          ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
