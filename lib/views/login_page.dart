import 'package:consultation_app/routes/app_router.dart';
import 'package:consultation_app/services/user_preferences.dart';
import 'package:consultation_app/utils/constants.dart';
import 'package:consultation_app/viewmodels/login_viewmodel.dart';
import 'package:consultation_app/views/consultations_user_page.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  LoginViewmodel _lvm = LoginViewmodel();
  Constants _constants = Constants();
  UserPreferences _userPreferences = UserPreferences();
  bool connected = false;
  @override
  void initState() {
    super.initState();
    checkIfInSharedPreferences();
  }

  void checkIfInSharedPreferences() async {
    String? token = await _userPreferences.getItem('token');
    String? email = await _userPreferences.getItem('email');

    if (token != null && email != null) {
      bool isExpired = JwtDecoder.isExpired(token);

      if (!isExpired) {
        Navigator.pushNamed(
          context,
          AppRouter.consultationsUserPage,
          arguments: ConsultationsUserPageArgs(token: token, email: email),
        );
      } else {
        // Optionally clear expired token
        await _userPreferences.removeItem('token');
        await _userPreferences.removeItem('email');
        print("Token expired, not navigating.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _constants.bgLight,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 150),
            Center(
              child: Text(
                'Join Consultation',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3D3D3D),
                ),
              ),
            ),

            SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 500,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  await _lvm.continueToVerify(
                    context,
                    emailController.text.trim(),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    const Color(0xFF10A64A),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Color(0xffffffff),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 500,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  _lvm.redirectToRegister(context);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    const Color.fromARGB(255, 0, 106, 255),
                  ),
                ),
                child: const Text(
                  'Register',
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
