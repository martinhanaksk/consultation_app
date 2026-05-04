// main.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Entry point of the Consultations app. Handles initialization,
// theme loading, session persistence, and root widget setup.

import 'package:flutter/material.dart';
import 'package:consultation_app/services/app_router.dart';
import 'package:overlay_kit/overlay_kit.dart';
import 'package:consultation_app/setup.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  // ensureInitialized is required before any plugin or async work in main()
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Keeps the native splash screen visible until we explicitly remove it later
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Registers all service locator dependencies (GetIt / injectable setup)
  setupDependencies();

  // Loads the user's saved theme preference (light/dark/system)
  await themeSelector.initialize();

  // Restores session state (e.g. logged-in user, tokens) from persistent storage
  await sm.load();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuilds the entire widget tree whenever the theme changes
    return ListenableBuilder(
      listenable: themeSelector,
      builder: (context, _) {
        // OverlayKit wraps the app to support global overlays (toasts, loaders)
        // without requiring a BuildContext at the call site
        return OverlayKit(
          child: MaterialApp(
            // Global navigator key allows navigation from outside the widget tree
            navigatorKey: nav.navigatorKey,
            title: 'Consultations',
            theme: ThemeData(
              primaryColor: constants.primary,
              // Applies color to all text selection handles and cursor
              textSelectionTheme: TextSelectionThemeData(
                cursorColor: constants.primary,
                selectionColor: constants.primary,
                selectionHandleColor: constants.primary,
              ),
            ),
            initialRoute: AppRouter.login,
            debugShowCheckedModeBanner: false,
            onGenerateRoute: AppRouter.generateRoute,
          ),
        );
      },
    );
  }
}
