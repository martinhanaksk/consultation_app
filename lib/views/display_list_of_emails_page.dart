import 'package:consultation_app/setup.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:flutter/material.dart';

class DisplayListOfEmailsPage extends StatefulWidget {
  final dynamic viewModel;
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
      appBar: AppBarMenu(),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            return Column(
              children: [
                Text(
                  "Allowed email domains",
                  style: TextStyle(
                    fontSize: constants.fsLabel,
                    color: constants.darkGrey150,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.viewModel.acceptedEmails.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.viewModel.acceptedEmails[index]),
                          IconButton(
                            icon: svgs.icon(
                              'trash',constants.red,
                              width: constants.fsTitle,
                              
                            ),
                            onPressed: () =>
                                widget.viewModel.removeFromAcceptedEmails(
                                  widget.viewModel.acceptedEmails[index],
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
