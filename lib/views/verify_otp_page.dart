import 'package:consultation_app/utils/constants.dart';
import 'package:consultation_app/viewmodels/verify_otp_viewmodel.dart';
import 'package:flutter/material.dart';

class VerifyOtpPage extends StatefulWidget {
  final String email;
  const VerifyOtpPage({super.key, required this.email});

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final TextEditingController otpcontroller = TextEditingController();
  VerifyOtpViewmodel _vovm = VerifyOtpViewmodel();Constants _constants = Constants();
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: _constants.bgLight,
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
                  backgroundColor: MaterialStateProperty.all(
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
