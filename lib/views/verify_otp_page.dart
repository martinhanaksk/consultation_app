// verify_otp_page.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// OTP verification screen shown after a successful login email submission.
// Accepts the 4-digit code sent to the user's email and completes authentication.

import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/verify_otp_viewmodel.dart';
import 'package:consultation_app/views/custom_widgets/app_bar_menu_widget.dart';
import 'package:consultation_app/views/custom_widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

// Passed via named route arguments from the login/register page
class VerifyOtpPageArgs {
  final String email;
  final bool rememberMe;
  VerifyOtpPageArgs({required this.email, required this.rememberMe});
}

class VerifyOtpPage extends StatefulWidget {
  final String email;
  final bool rememberMe;
  const VerifyOtpPage({
    super.key,
    required this.email,
    required this.rememberMe,
  });

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  late final VerifyOtpViewmodel _viewModel;
  final TextEditingController otpcontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ViewModel is created here rather than inside build() to prevent
    // re-instantiation on every rebuild
    _viewModel = VerifyOtpViewmodel();
  }

  @override
  void dispose() {
    otpcontroller.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The viewmodel lifecycle is managed by this State
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<VerifyOtpViewmodel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBarMenu(onVerificationPage: true),
            backgroundColor: constants.background,
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 200),
                    Text(
                      'Verification',
                      style: TextStyle(
                        fontSize: constants.fsHeadline,
                        fontWeight: constants.fwSemiBold,
                        color: constants.darkGrey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'Enter OTP from email.',
                        style: TextStyle(
                          fontSize: constants.fsLabel,
                          fontWeight: constants.fwRegular,
                          color: constants.darkGrey150,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      clipBehavior: Clip.none,
                      decoration: constants.squircleShadow(
                        color: constants.background,
                      ),
                      child: CustomInputTextField(
                        controller: otpcontroller,
                        hintText: "Code",
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        textCounterEnabled: false,
                      ),
                    ),
                    SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      // Replaces the button with a spinner for the duration of the API call
                      child: viewModel.isLoading()
                          ? SpinKitPouringHourGlass(
                              color: constants.primary,
                              size: constants.fsBody,
                            )
                          : ElevatedButton(
                              onPressed: () {
                                // Dismiss keyboard before triggering the network request
                                FocusScope.of(context).unfocus();
                                viewModel.connect(
                                  widget.email,
                                  otpcontroller.text.trim(),
                                  widget.rememberMe,
                                );
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
                                'Connect',
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
