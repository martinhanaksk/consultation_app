import 'package:consultation_app/utils/constants.dart';
import 'package:consultation_app/viewmodels/verifyOtp_viewmodel.dart';
import 'package:flutter/material.dart';

class VerifyOtpPageArgs {
  final String email;
  final String testingToken;
  final bool rememberMe;
  VerifyOtpPageArgs({
    required this.email,
    required this.testingToken,
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
  final VerifyOtpViewmodel _vovm = VerifyOtpViewmodel();
  final Constants _constants = Constants();
  @override
  void initState() {
    super.initState();
    if (widget.token.isNotEmpty) {
      otpcontroller.text = widget.token.substring(1, widget.token.length - 1);

      _vovm.connect(context, widget.email, otpcontroller.text.trim(),widget.rememberMe);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _constants.bgLight,
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: [
            SizedBox(height: 200),
            Text(
              'Verification',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3D3D3D),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Please enter the OTP from your email.',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3D3D3D),
              ),
            ),
            SizedBox(height: 20),
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
                onPressed: () async {
                  _vovm.connect(
                    context,
                    widget.email,
                    otpcontroller.text.trim(),widget.rememberMe
                  );
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    _constants.primaryColor,
                  ),
                ),
                child: Text(
                  'Connect',
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
    );
  }
}
