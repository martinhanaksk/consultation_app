import 'package:consultation_app/routes/appRouter.dart';
import 'package:consultation_app/services/userPreferences.dart';
import 'package:consultation_app/utils/constants.dart';
import 'package:consultation_app/utils/helperFunctions.dart';
import 'package:consultation_app/utils/notifyUserUtils.dart';
import 'package:consultation_app/utils/validator.dart';
import 'package:consultation_app/viewmodels/emailInput_viewmodel.dart';
import 'package:consultation_app/views/consultationsStudent_page.dart';
import 'package:consultation_app/views/consultationsTeacher_page.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class EmailInputPage extends StatefulWidget {
  const EmailInputPage({super.key});

  @override
  State<EmailInputPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<EmailInputPage> {
  final TextEditingController emailController = TextEditingController();
  final HelperFunctions _helperFunctions = HelperFunctions();
  EmailInputViewmodel _lvm = EmailInputViewmodel();
  Constants _constants = Constants();
  NotifyUserUtils dialogs = NotifyUserUtils();
  UserPreferences _userPreferences = UserPreferences();
  Validator _validator = Validator();
  bool isChecked = false;
  bool connected = false;
  @override
  void initState() {
    super.initState();
    checkIfInSharedPreferences();
  }

  void checkIfInSharedPreferences() async {
    String? token = await _userPreferences.getItem('token');
    String? email = await _userPreferences.getItem('email');
    String? role = await _userPreferences.getItem('role');
    if (token != null &&
        email != null &&
        role != null &&
        role.isNotEmpty &&
        token.isNotEmpty &&
        email.isNotEmpty) {
      bool isExpired = JwtDecoder.isExpired(token);

      if (!isExpired) {
        if (role == 'teacher') {
          Navigator.pushNamed(
            context,
            AppRouter.consultationsTeacherPage,
            arguments: ConsultationsTeacherPageArgs(token: token, email: email),
          );
        } else if (role == 'student') {
          Navigator.pushNamed(
            context,
            AppRouter.consultationsStudentPage,
            arguments: ConsultationsStudentPageArgs(token: token, email: email),
          );
        }
      } else {
        // Optionally clear expired token
        await _userPreferences.removeItem('token');
        await _userPreferences.removeItem('email');
        await _userPreferences.removeItem('role');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _constants.bgLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 80),
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
              SizedBox(height: 15),
              Row(
                children: [
                  Checkbox(
                    value: isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isChecked = value ?? false;
                      });
                    },
                  ),
                  Text('Remember me'),
                ],
              ),
              SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
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
                          _helperFunctions.trimText(
                            emailController.text.trim(),
                          ),
                          isChecked,
                        );
                      }
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      _constants.primaryColor,
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
      ),
    );
  }
}
