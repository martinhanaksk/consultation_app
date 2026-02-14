import 'package:consultation_app/utils/constants.dart';
import 'package:consultation_app/utils/helper_functions.dart';
import 'package:consultation_app/utils/notify_user_utils.dart';
import 'package:consultation_app/utils/validator.dart';
import 'package:consultation_app/viewmodels/email_input_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:consultation_app/setup.dart'; 

class EmailInputPage extends StatefulWidget {
  const EmailInputPage({super.key});

  @override
  State<EmailInputPage> createState() => _EmailInputPageState();
}

class _EmailInputPageState extends State<EmailInputPage> {
  final _constants = getIt<Constants>();
  final _helperFunctions = getIt<HelperFunctions>();
  final _validator = getIt<Validator>();
  final _notifyUserUtils = getIt<NotifyUserUtils>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EmailInputViewModel(),
      child: Consumer<EmailInputViewModel>(
        builder: (context, viewModel, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            viewModel.checkIfInSharedPreferences(context);
          });
          return Scaffold(
            backgroundColor: _constants.bgLight,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80),
                    Center(
                      child: Image.asset(
                        'assets/images/applogo.png',
                        width: 230,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 50),
                    TextField(
                      onChanged: viewModel.updateEmail,
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Checkbox(
                          value: viewModel.isChecked,
                          onChanged: viewModel.toggleRememberMe,
                        ),

                        Text('Remember me'),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (viewModel.email.isEmpty) {
                            _notifyUserUtils.showToast(
                              'Please type in your email.',
                            );
                          } else {
                            if (!viewModel.isLoading &&
                                _validator.validateEmail(
                                  viewModel.email.trim(),
                                  context,
                                )) {
                              await viewModel.continueToVerify(
                                context,
                                _helperFunctions.trimText(
                                  viewModel.email.trim(),
                                ),
                                viewModel.isChecked,
                              );
                            }
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            _constants.primaryColor,
                          ),
                        ),
                        child: viewModel.isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Next',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xffffffff),
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
