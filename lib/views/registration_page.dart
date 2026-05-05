// registration_page.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Registration form shown when a login attempt discoveres unregistered email.
// The email field is pre-filled and read-only in practice — the user arrived here
// from the login flow so the address is already known.

import 'package:consultation_app/models/user_model.dart';
import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/register_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class RegistrationPage extends StatefulWidget {
  final String email;
  final bool rememberMe;
  const RegistrationPage({
    super.key,
    required this.email,
    required this.rememberMe,
  });

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController visitReasonController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fills the email field with the address carried over from the login page
    emailController.text = widget.email;
  }

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    visitReasonController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider with create: is used here because this page
    // owns the viewmodel lifecycle
    return ChangeNotifierProvider(
      create: (_) => RegisterViewmodel(),
      child: Consumer<RegisterViewmodel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBarMenu(onRegistrationPage: true),
            backgroundColor: constants.background,
            // Allows the form to scroll up when the keyboard appears
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 72),
                    Center(
                      child: Text(
                        'Create new account',
                        style: TextStyle(
                          fontSize: constants.fsHeadline,
                          fontWeight: constants.fwSemiBold,
                          color: constants.darkGrey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomInputTextField(
                      controller: emailController,
                      readOnly: true,
                      hintText: 'Email',
                      isEmail: true,
                      maxLength: 50,
                    ),
                    const SizedBox(height: 16),
                    CustomInputTextField(
                      controller: nameController,
                      hintText: 'Name',
                      maxLength: 50,
                    ),
                    const SizedBox(height: 16),
                    CustomInputTextField(
                      controller: surnameController,
                      hintText: 'Surname',
                      maxLength: 50,
                    ),
                    const SizedBox(height: 16),
                    CustomInputTextField(
                      controller: visitReasonController,
                      hintText: 'Visit reason',
                      maxLength: 50,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: viewModel.isLoading
                          ? SpinKitPouringHourGlass(
                              color: constants.green,
                              size: constants.fsTitle,
                            )
                          : ElevatedButton(
                              onPressed: () async {
                                FocusScope.of(context).unfocus();
                                // All fields must be non-empty, email was checked sooner
                                if (
                                    validator.validateNotEmpty(
                                      nameController.text.trim(),
                                      context,
                                    ) &&
                                    validator.validateNotEmpty(
                                      surnameController.text.trim(),
                                      context,
                                    ) &&
                                    validator.validateNotEmpty(
                                      visitReasonController.text.trim(),
                                      context,
                                    )) {
                                  try {
                                    // role, visible, and notification are not used yet, user model here serves
                                    // just to pass email, name, surname and visit reason
                                    UserModel um = UserModel(
                                      email: helpers.trimText(
                                        emailController.text.trim(),
                                      ),
                                      name: helpers.trimText(
                                        nameController.text.trim(),
                                      ),
                                      surname: helpers.trimText(
                                        surnameController.text.trim(),
                                      ),
                                      role: '',
                                      visitReason: helpers.trimText(
                                        visitReasonController.text.trim(),
                                      ),
                                      visible: 0,
                                      notification: 0,
                                    );
                                    await viewModel.handleRegisterUser(
                                      um,
                                      widget.rememberMe,
                                    );
                                  } catch (e) {
                                    notify.showToast(
                                      "Error while registering user",
                                      isError: true,
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: constants.green,
                                disabledBackgroundColor: constants.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 2,
                                shadowColor: constants.green,
                              ),
                              child: Text(
                                'Register',
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
          );
        },
      ),
    );
  }
}
