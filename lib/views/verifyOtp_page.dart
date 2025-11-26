import 'package:consultation_app/utils/constants.dart';
import 'package:consultation_app/viewmodels/verifyOtp_viewmodel.dart';
import 'package:flutter/material.dart';

class VerifyOtpPageArgs {
  final String email;
  final String testingToken;

  VerifyOtpPageArgs({required this.email, required this.testingToken});
}

class VerifyOtpPage extends StatefulWidget {
  final String email;
  final String testingToken;
  const VerifyOtpPage({
    super.key,
    required this.email,
    required this.testingToken,
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
    if (widget.testingToken.isNotEmpty) {
      otpcontroller.text = widget.testingToken.substring(
        1,
        widget.testingToken.length - 1,
      );

      _vovm.connect(context, widget.email, otpcontroller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _constants.bgLight,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              'Verification',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3D3D3D),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: otpcontroller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'eg.1234',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  _vovm.connect(
                    context,
                    widget.email,
                    otpcontroller.text.trim(),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    const Color(0xFF10A64A),
                  ),
                ),
                child: const Text(
                  'Connect',
                  style: TextStyle(color: Color(0xffffffff)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
