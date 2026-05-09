// display_list_of_emails_page.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Displays and manages the list of allowed email domains/addresses for a room.

import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/base_room_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:flutter/material.dart';

class DisplayListOfEmailsPage extends StatefulWidget {
  // Typed as dynamic to accept both EditRoomViewModel and CreateRoomPageViewModel
  final BaseRoomViewModel viewModel;

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
          // Rebuilds the list whenever an entry is added or removed in the parent viewmodel
          listenable: widget.viewModel,
          builder: (context, _) {
            return Column(
              children: [
                Text(
                  "Allowed email domains",
                  style: TextStyle(
                    fontWeight: constants.fwSemiBold,
                    fontSize: constants.fsTitle,
                    color: constants.darkGrey,
                  ),
                ),
                Expanded(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      overscroll: false,
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: widget.viewModel.acceptedEmails.length,
                      itemBuilder: (context, index) {
                        final emailDomain =
                            widget.viewModel.acceptedEmails[index];

                        return Container(
                          decoration: constants.squircleShadow(
                            color: constants.background,
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 2.0,
                            ),
                            title: Text(
                              emailDomain,
                              style: TextStyle(
                                color: constants.darkGrey,
                                fontWeight: constants.fwSemiBold,
                              ),
                            ),
                            trailing: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => widget.viewModel
                                  .removeFromAcceptedEmails(emailDomain),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: svgs.icon(
                                  'trash',
                                  constants.red,
                                  width: constants.fsTitle,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
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
