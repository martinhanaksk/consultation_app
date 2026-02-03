import 'package:consultation_app/models/user_model.dart';
import 'package:consultation_app/utils/constants.dart';
import 'package:consultation_app/utils/helperFunctions.dart';
import 'package:consultation_app/utils/notifyUserUtils.dart';
import 'package:consultation_app/utils/validator.dart';
import 'package:consultation_app/viewmodels/register_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistrationPage extends StatefulWidget {
  final String email;
  const RegistrationPage({super.key, required this.email});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final HelperFunctions _helperFunctions = HelperFunctions();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController visitReasonController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final RegisterViewmodel _rvm = RegisterViewmodel();
  final Constants _constants = Constants();
  final Validator _validator = Validator();
  final NotifyUserUtils dialogs = NotifyUserUtils();
  bool _isLoading = false;

  Future<void> registerUser(String email) async {
    final email = emailController.text.trim();
    final response = await http.post(
      Uri.parse('${_constants.url}/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode == 200) {
      //todo
    } else {
      dialogs.showToast('Failed to send OTP. Try again.');
    }
  }

  @override
  void initState() {
    super.initState();
    emailController.text = widget.email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _constants.bgLight,
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
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3D3D3D),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  hintText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: surnameController,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  hintText: 'Surname',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: visitReasonController,
                enabled: !_isLoading,
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
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_validator.validateNotEmpty(
                                emailController.text.trim(),
                                'E-mail',
                                context,
                              ) &&
                              _validator.validateNotEmpty(
                                nameController.text.trim(),
                                'Name',
                                context,
                              ) &&
                              _validator.validateNotEmpty(
                                surnameController.text.trim(),
                                'Surname',
                                context,
                              ) &&
                              _validator.validateNotEmpty(
                                visitReasonController.text.trim(),
                                'Visit reason',
                                context,
                              ) &&
                              _validator.validateEmail(
                                emailController.text.trim(),
                                context,
                              )) {
                            setState(() {
                              _isLoading = true;
                            });

                            try {
                              UserModel um = UserModel(
                                email: _helperFunctions.trimText(
                                  emailController.text.trim(),
                                ),
                                name: _helperFunctions.trimText(
                                  nameController.text.trim(),
                                ),
                                surname: _helperFunctions.trimText(
                                  surnameController.text.trim(),
                                ),
                                role: '',
                                visitReason: _helperFunctions.trimText(
                                  visitReasonController.text.trim(),
                                ),
                                visible: 0,
                              );
                              await _rvm.registerUser(context, um);
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            }
                          }
                        },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      const Color(0xFF10A64A),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
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
  }
}
