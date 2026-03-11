import 'package:consultation_app/viewmodels/email_input_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:consultation_app/setup.dart';
import 'package:figma_squircle/figma_squircle.dart';
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
      helpers.checkIfInSharedPreferences();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EmailInputViewModel(),
      child: Consumer<EmailInputViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
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
                        child: Image.asset(
                          'assets/resources/applogo.png',
                          width: 230,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 50),
                      Container(
                        clipBehavior: Clip.none,
                        decoration: constants.figmaLightShadowWith(
                          color: constants.ghostWhite,
                          borderRadius: SmoothBorderRadius(
    cornerRadius: 12,
    cornerSmoothing: 0.6,
  ),
                        ),
                        child: TextField(
                          onChanged: viewModel.updateEmail,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),

                            hintText: 'Email',
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          IntrinsicWidth(
                            child: Container(
                              width: 25,
                              height: 25,
                              clipBehavior: Clip.none,
                              decoration: constants.figmaLightShadowWith(
                                color: constants.ghostWhite,
                                borderRadius: SmoothBorderRadius(
    cornerRadius: 6,
    cornerSmoothing: 0.6,
  ),
                              ),
                              child: Checkbox(
                                value: viewModel.isChecked,
                                onChanged: viewModel.toggleRememberMe,
                                side: BorderSide.none,
                                checkColor: constants.darkGrey,
                                fillColor: WidgetStateProperty.all(
                                  constants.ghostWhite,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          const Text('Remember me'),
                        ],
                      ),
                      SizedBox(),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!viewModel.isLoading &&
                                validator.validateEmail(
                                  viewModel.email,
                                  context,
                                )) {
                              await viewModel.continueToVerify(
                                helpers.trimText(viewModel.email),
                                viewModel.isChecked,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: constants.primary,
                            disabledBackgroundColor: constants.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 2,
                            shadowColor: constants.primary.withValues(
                              alpha: 0.4,
                            ),
                          ),
                          child: viewModel.isLoading
                              ? CircularProgressIndicator(
                                  color: constants.ghostWhite,
                                )
                              : Text(
                                  'Next',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                    color: constants.ghostWhite,
                                  ),
                                ),
                        ),
                      ),
                    ],
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
