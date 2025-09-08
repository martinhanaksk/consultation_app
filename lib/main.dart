import 'package:flutter/material.dart';
import 'package:consultation_app/routes/app_router.dart';

// Author: Martin Hanak
// email:  xhanakm00@stud.fit.vut.cz
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Consultations',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: AppRouter.cousultationsUserPage,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
