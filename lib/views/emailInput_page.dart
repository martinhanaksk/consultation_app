import 'package:consultation_app/routes/app_router.dart';
import 'package:consultation_app/services/user_preferences.dart';
import 'package:consultation_app/utils/constants.dart';
import 'package:consultation_app/utils/notifyUserUtils.dart';
import 'package:consultation_app/utils/validator.dart';
import 'package:consultation_app/viewmodels/emailInput_viewmodel.dart';
import 'package:consultation_app/views/consultationsStudent_page.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class EmailInputPage extends StatefulWidget {
  const EmailInputPage({super.key});

  @override
  State<EmailInputPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<EmailInputPage> {
  final TextEditingController emailController = TextEditingController();
  EmailInputViewmodel _lvm = EmailInputViewmodel();
  Constants _constants = Constants();
  NotifyUserUtils dialogs = NotifyUserUtils();
  UserPreferences _userPreferences = UserPreferences();
  Validator _validator = Validator();
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
            SizedBox(height: 50),
            Center(
              child: Image.asset(
                'assets/images/applogo.png',

                width: 230,
                fit: BoxFit.cover,
              ),
            ),

            SizedBox(height: 50),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 25),
            SizedBox(
              width: 500,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  if (emailController.text.trim().isEmpty) {
                    dialogs.showToast('Please type in your email.');
                  } else {
                    if (_validator.validateEmail(
                      emailController.text.trim(),
                      context,
                    )) {
                      await _lvm.continueToVerify(
                        context,
                        emailController.text.trim(),
                      );
                    }
                  }
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    const Color(0xff0071e2),
                  ),
                ),
                child: const Text(
                  'Next',
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
