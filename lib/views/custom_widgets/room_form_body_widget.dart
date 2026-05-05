// room_form_body.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Shared form layout for CreateRoom and EditRoomPage.
// Owns all repeated UI; each caller supplies only the parts that differ.

import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/base_room_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class RoomFormBody extends StatelessWidget {
  final String pageTitle;
  final BaseRoomViewmodel viewModel;
  final bool isSubmitting;
  final String submitLabel;
  final VoidCallback onSubmit;


  const RoomFormBody({
    super.key,
    required this.pageTitle,
    required this.viewModel,
    required this.isSubmitting,
    required this.submitLabel,
    required this.onSubmit,
  });


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PageTitle(pageTitle),
            const SizedBox(height: 20),
            CustomInputTextField(
              controller: viewModel.titleController,
              hintText: "Title (e.g. Martin's room)",
            ),
            const SizedBox(height: 20),
            // URL field — uses isUrl flag to restrict characters and set the correct keyboard
            CustomInputTextField(
              controller: viewModel.shortNameController,
              hintText: 'https://example.com',
              isUrl: true,
              maxLength: 2000,
            ),
            const SizedBox(height: 20),
            CustomInputTextField(
              controller: viewModel.descriptionController,
              hintText: 'Description (e.g. D105)',
            ),
            const SizedBox(height: 20),
            // Number-only field; maxLength 4 caps the value at 9999 hours
            CustomInputTextField(
              controller: viewModel.cancellationHoursController,
              hintText: 'Cancel deadline in hours',
              keyboardType: TextInputType.number,
              maxLines: 1,
              maxLength: 4,
            ),
            const SizedBox(height: 20),
            _EmailDomainField(viewModel: viewModel, context: context),
            const SizedBox(height: 16),
            _ViewDomainsLink(viewModel: viewModel),
            const SizedBox(height: 16),
            // Replace the submit button with a spinner while the request is in progress
            isSubmitting
                ? Center(
                    child: SpinKitPouringHourGlass(
                      color: constants.primary,
                      size: constants.fsHeadline,
                    ),
                  )
                : _SubmitButton(label: submitLabel, onPressed: onSubmit),
          ],
        ),
      ),
    );
  }
}

// ─── Private sub-widgets ────────────────────────────────────────────────────

class _PageTitle extends StatelessWidget {
  final String title;
  const _PageTitle(this.title);


  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: constants.fsHeadline,
            fontWeight: constants.fwSemiBold,
            color: constants.darkGrey,
          ),
        ),
      );
}

class _EmailDomainField extends StatelessWidget {
  final BaseRoomViewmodel viewModel;
  final BuildContext context;
  const _EmailDomainField({required this.viewModel, required this.context});


  @override
  Widget build(BuildContext ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              'Allowed email domains',
              style: TextStyle(
                fontSize: constants.fsLabel,
                color: constants.darkGrey100,
              ),
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            maxLength: 50,
            // Restricts input to valid email/domain characters
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[a-zA-Z0-9@._\-+]'),
              ),
            ],
            style: TextStyle(color: constants.darkGrey),
            controller: viewModel.acceptedEmailController,
            decoration: InputDecoration(
              counterText: '',
              hintText: '@domain.com, user@domain.com..',
              border: _border(constants.grey),
              enabledBorder: _border(constants.grey),
              // Highlight border with primary color and slightly thicker stroke on focus
              focusedBorder: _border(constants.primary, width: 1.5),
              suffixIcon: GestureDetector(
                onTap: () {
                  // Validate before adding; validator shows its own error feedback
                  if (validator.validateNotEmpty(
                    viewModel.acceptedEmailController.text.trim(),
                    context,
                  )) {
                    viewModel.addToAcceptedEmails(
                      helpers.trimText(
                        viewModel.acceptedEmailController.text.trim(),
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: svgs.icon('add', constants.primary, width: constants.fsBody),
                ),
              ),
            ),
          ),
        ],
      );

  OutlineInputBorder _border(Color color, {double width = 1.0}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
}


class _ViewDomainsLink extends StatelessWidget {
  final BaseRoomViewmodel viewModel;
  const _ViewDomainsLink({required this.viewModel});


  @override
  Widget build(BuildContext context) => Center(
        child: GestureDetector(
          onTap: () => nav.toDisplayListOfEmails(viewModel: viewModel),
          child: Text(
            // Live count lets the user see how many domains are already saved
            'View added domains (${viewModel.acceptedEmails.length})',
            style: TextStyle(
              color: constants.primary,
              fontSize: constants.fsLabel,
              fontWeight: constants.fwSemiBold,
              decoration: TextDecoration.underline,
              decorationColor: constants.primary,
            ),
          ),
        ),
      );
}


class _SubmitButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _SubmitButton({required this.label, required this.onPressed});


  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: onPressed,
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
            label,
            style: TextStyle(
              fontSize: constants.fsBody,
              fontWeight: constants.fwSemiBold,
              color: constants.background,
            ),
          ),
        ),
      );
}
