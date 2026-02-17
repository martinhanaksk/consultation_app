import 'package:consultation_app/setup.dart';
import 'package:consultation_app/viewmodels/verify_otp_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  final TextEditingController otpcontroller = TextEditingController();
  @override
  void initState() {
    super.initState();
    if (widget.token.isNotEmpty) {
      //testing otp
      otpcontroller.text = widget.token.substring(1, widget.token.length - 1);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<VerifyOtpViewmodel>(context, listen: false).connect(
          context,
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VerifyOtpViewmodel(),
      child: Consumer<VerifyOtpViewmodel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: constants.bgLight,
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 200),
                    Text(
                      'Verification',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: constants.defaultDarkGrey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Please enter the OTP from your email.',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: constants.defaultDarkGrey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: otpcontroller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'eg. 1234',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading()
                            ? null
                            : () {
                                viewModel.connect(
                                  context,
                                  widget.email,
                                  otpcontroller.text.trim(),
                                  widget.rememberMe,
                                );
                              },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            constants.primaryColor,
                          ),
                        ),
                        child: Text(
                          'Connect',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: constants.defaultWhite,
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
