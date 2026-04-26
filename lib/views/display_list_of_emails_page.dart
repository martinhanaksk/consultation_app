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
                    fontSize: constants.fsBody,
                    color: constants.darkGrey150,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: widget.viewModel.acceptedEmails.length,
                    itemBuilder: (context, index) {
                      final emailDomain =
                          widget.viewModel.acceptedEmails[index];

                      return Container(
                        decoration: constants.squircleShadow(
                          color: constants.lightPrimary,
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
                          // 4. Moved the delete button to 'trailing' and gave it a better touch target
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
              ],
            );
          },
        ),
      ),
    );
  }
}
