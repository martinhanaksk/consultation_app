import 'package:flutter/material.dart';
import 'package:consultation_app/services/app_router.dart';
import 'package:overlay_kit/overlay_kit.dart';
import 'package:consultation_app/setup.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

// Author: Martin Hanak
// email: xhanakm00@stud.fit.vut.cz
void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OverlayKit(
      child: MaterialApp(
        title: 'Consultations',
        navigatorKey: nav.navigatorKey,
        theme: ThemeData(primaryColor: constants.primary),
        initialRoute: AppRouter.login,
        debugShowCheckedModeBanner: false,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
