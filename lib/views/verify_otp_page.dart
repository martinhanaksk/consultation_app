import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/verify_otp_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:figma_squircle/figma_squircle.dart';

class VerifyOtpPageArgs {
  final String email;
  final String token;
  final bool rememberMe;
  VerifyOtpPageArgs({
    required this.email,
    required this.token,
    required this.rememberMe,
  });
}

class VerifyOtpPage extends StatefulWidget {
  final String email;
  final String token;
  final bool rememberMe;
  const VerifyOtpPage({
    super.key,
    required this.email,
    required this.token,
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
    _viewModel = VerifyOtpViewmodel();

    if (widget.token.isNotEmpty) {
      otpcontroller.text = widget.token.substring(1, widget.token.length - 1);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _viewModel.connect(
          widget.email,
          otpcontroller.text.trim(),
          widget.rememberMe,
        );
      });
    }
  }

  @override
  void dispose() {
    otpcontroller.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<VerifyOtpViewmodel>(
        builder: (context, viewModel, child) {
          return Scaffold(
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
                          color: constants.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
                        controller: otpcontroller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),

                          hintText: 'Code',
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading()
                            ? null
                            : () {
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
