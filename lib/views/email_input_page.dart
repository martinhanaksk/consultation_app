import 'package:consultation_app/viewmodels/email_input_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/custom_checkbox_widget.dart';
import 'package:consultation_app/views/custom_widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:consultation_app/setup.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'dart:async';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class EmailInputPage extends StatefulWidget {
  const EmailInputPage({super.key});

  @override
  State<EmailInputPage> createState() => _EmailInputPageState();
}

class _EmailInputPageState extends State<EmailInputPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
      sm.checkIfInSharedPreferences();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EmailInputViewModel(),
      child: Consumer<EmailInputViewModel>(
        builder: (context, viewModel, child) {
          return PopScope(
            canPop: false,
            child: Scaffold(
              backgroundColor: constants.background,
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 80),
                        Center(
                          child: svgs.icon(
                            "logo-whole",
                            constants.primary,
                            width: 232,
                          ),
                        ),
                        const SizedBox(height: 56),
                        CustomInputTextField(
                          hintText: 'Email',
                          controller: viewModel.emailController,
                          isEmail: true,
                          maxLength: 50,
                        ),

                        const SizedBox(height: 12),
                        Row(
                          children: [
                            CustomCheckbox(
                              value: viewModel.isChecked,
                              onChanged: viewModel.toggleRememberMe,
                            ),

                            SizedBox(width: 4),
                            Text(
                              'Remember me',
                              style: TextStyle(
                                color: constants.darkGrey,
                                fontSize: constants.fsBody,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: viewModel.isLoading
                              ? Center(
                                  child: SpinKitPouringHourGlass(
                                    color: constants.primary,
                                    size: constants.fsTitle,
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: () async {
                                    FocusScope.of(context).unfocus();
                                    if (!viewModel.isLoading &&
                                        validator.validateEmail(
                                          viewModel.email,
                                          context,
                                        )) {
                                      viewModel.startLoadingTimeout();

                                      await viewModel.continueToVerify(context);
                                    }
                                  },
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
                                    'Next',
                                    style: TextStyle(
                                      fontSize: constants.fsTitle,
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
              ),
            ),
          );
        },
      ),
    );
  }
}
