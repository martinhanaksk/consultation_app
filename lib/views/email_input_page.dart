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
          final viewModel = EmailInputViewModel();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            viewModel.checkIfInSharedPreferences(context);
          });
          return Scaffold(
            backgroundColor: constants.bgLight,
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
                        const Text('Remember me'),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!viewModel.isLoading &&
                              validator.validateEmail(
                                viewModel.email.trim(),
                                context,
                              )) {
                            await viewModel.continueToVerify(
                              context,
                              helpers.trimText(viewModel.email.trim()),
                              viewModel.isChecked,
                            );
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            constants.primaryColor,
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
