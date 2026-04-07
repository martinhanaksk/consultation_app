import 'package:consultation_app/models/user_model.dart';
import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/register_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

class RegistrationPage extends StatefulWidget {
  final String email;
  const RegistrationPage({super.key, required this.email});

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
    return ChangeNotifierProvider(
      create: (_) => RegisterViewmodel(),
      child: Consumer<RegisterViewmodel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: constants.background,
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
                        'Register',
                        style: TextStyle(
                          fontSize: constants.fsHeadline,
                          fontWeight: constants.fwSemiBold,
                          color: constants.darkGrey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      scrollPadding: EdgeInsets.only(bottom: 1000),
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
                        hintText: 'Email',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      scrollPadding: EdgeInsets.only(bottom: 1000),
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
                        hintText: 'Name',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: surnameController,
                      scrollPadding: EdgeInsets.only(bottom: 1000),
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
                        hintText: 'Surname',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: visitReasonController,
                      scrollPadding: EdgeInsets.only(bottom: 1000),
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
                        hintText: 'Visit reason',
                      ),
                    ),

                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          if (validator.validateNotEmpty(
                                emailController.text.trim(),

                                context,
                              ) &&
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
                              ) &&
                              validator.validateEmail(
                                emailController.text.trim(),
                                context,
                              )) {
                            try {
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
                              );
                              await viewModel.registerUser(um);
                            } catch (e) {
                              notify.showToast("Error while registering user.");
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
