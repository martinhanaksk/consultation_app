import 'package:consultation_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:consultation_app/routes/appRouter.dart';
import 'package:overlay_kit/overlay_kit.dart';

// Author: Martin Hanak
// email:  xhanakm00@stud.fit.vut.cz
Constants _constants = Constants();
void main() {
  runApp(const MyApp());
  _constants.checkIfTestingServer(false);
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
