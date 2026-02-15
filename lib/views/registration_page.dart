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
            backgroundColor: constants.bgLight,
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 70),
                    Center(
                      child: Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: constants.defaultDarkGrey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: surnameController,
                      decoration: const InputDecoration(
                        hintText: 'Surname',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: visitReasonController,
                      decoration: const InputDecoration(
                        hintText: 'Visit reason',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (validator.validateNotEmpty(
                                emailController.text.trim(),
                                'E-mail',
                                context,
                              ) &&
                              validator.validateNotEmpty(
                                nameController.text.trim(),
                                'Name',
                                context,
                              ) &&
                              validator.validateNotEmpty(
                                surnameController.text.trim(),
                                'Surname',
                                context,
                              ) &&
                              validator.validateNotEmpty(
                                visitReasonController.text.trim(),
                                'Visit reason',
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
                              await viewModel.registerUser(context, um);
                            } catch (e) {}
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            constants.defaultGreen,
                          ),
                        ),
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
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
