import 'package:consultation_app/viewmodels/email_input_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:consultation_app/setup.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'dart:async';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/flutter_svg.dart';
class EmailInputPage extends StatefulWidget {
  const EmailInputPage({super.key});

  @override
  State<EmailInputPage> createState() => _EmailInputPageState();
}

class _EmailInputPageState extends State<EmailInputPage> {
  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
      helpers.checkIfInSharedPreferences();
    });
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  void _startLoadingTimeout(BuildContext context) {
    _loadingTimer?.cancel();
    _loadingTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        final viewModel = Provider.of<EmailInputViewModel>(
          context,
          listen: false,
        );
        viewModel.setLoading(false);
      }
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
              child: viewModel.isLoading
                  ? Center(
                      child: SpinKitPouringHourGlass(
                        color: constants.primary,
                        size: constants.fsHeadline,
                      ),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 80),
                            Center(
                              child: SvgPicture.asset(
                                'assets/resources/logo-whole.svg',
                                width: 232,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 56),
                            Container(
                              clipBehavior: Clip.none,
                              decoration: constants.figmaLightShadowWith(
                                color: constants.background,
                                borderRadius: SmoothBorderRadius(
                                  cornerRadius: 12,
                                  cornerSmoothing: 0.6,
                                ),
                              ),
                              child: TextField(scrollPadding: EdgeInsets.only(bottom: 1000),
                                onChanged: viewModel.updateEmail,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  hintText: 'Email',
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                IntrinsicWidth(
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    clipBehavior: Clip.none,
                                    decoration: constants.figmaLightShadowWith(
                                      color: constants.background,
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
                                        constants.background,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                const Text('Remember me'),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (!viewModel.isLoading &&
                                      validator.validateEmail(
                                        viewModel.email,
                                        context,
                                      )) {
                                    // Start 5-second timeout before API call
                                    _startLoadingTimeout(context);

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
          );
        },
      ),
    );
  }
}
