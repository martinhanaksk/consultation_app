import 'package:consultation_app/models/user_model.dart';
import 'package:consultation_app/utils/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:consultation_app/routes/app_router.dart';

class RegisterViewmodel {
  Dialogs dialogs = Dialogs();
  Future<void> registerUser(BuildContext context, UserModel um) async {
    final response = await http.post(
      Uri.parse(
        'https://consultations-backend.onrender.com/users/register?email=${um.email}',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": um.email,
        "name": um.name,
        "surname": um.surname,
        "visit_reason": um.visitReason,
      }),
    );
    if (response.statusCode == 200) {
      Navigator.pushNamed(
        context,
        AppRouter.cousultationsUserPage,
        //TODO token nie email
        arguments: um.email,
      );
    } else {
      dialogs.showErrorDialog(context, 'Failed to registeruser. Try again.');
    }
  }
}
