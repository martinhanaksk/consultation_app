import 'package:consultation_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WelcomePage extends StatefulWidget {
  final String token;
  WelcomePage({super.key, required this.token});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  dynamic data;Constants _constants = Constants();
  Future<void> showUsers() async {
    final bearerToken = widget.token;
    final response = await http.get(
      Uri.parse('https://consultations-backend.onrender.com/users'),
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        data = jsonDecode(response.body);
      });
    } else {
      print("Failed to load users: ${response.statusCode}");
    }
  }

  @override
  void initState() {
    super.initState();
    showUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: _constants.bgLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            const Text(
              "Welcome!",
              style: TextStyle(color: Color(0xFF10A64A), fontSize: 32),
            ),
            const SizedBox(height: 10),
            data == null
                ? const CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final user = data[index];
                        return ListTile(
                          title: Text(user['email'] ?? 'No email'),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
