import 'package:flutter/material.dart';
import 'package:consultation_app/routes/app_router.dart';
import 'package:overlay_kit/overlay_kit.dart';

// Author: Martin Hanak
// email:  xhanakm00@stud.fit.vut.cz
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OverlayKit(
      child: MaterialApp(
        title: 'Consultations',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: AppRouter.login,
        debugShowCheckedModeBanner: false,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
