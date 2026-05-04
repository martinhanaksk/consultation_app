// setup.dart
// Author: Martin Hanak
// Email: xhanakm00@stud.fit.vut.cz
// Configures the GetIt service locator: registers all app-wide singletons
// and exposes them as top-level getters for convenient access across the app.

import 'package:consultation_app/services/api_service.dart';
import 'package:consultation_app/services/navigation_service.dart';
import 'package:consultation_app/services/session_manager.dart';
import 'package:consultation_app/services/user_preferences.dart';
import 'package:consultation_app/utils/app_svg.dart';
import 'package:consultation_app/utils/constants.dart';
import 'package:consultation_app/utils/helper_functions.dart';
import 'package:consultation_app/utils/notify_user_utils.dart';
import 'package:consultation_app/utils/theme_selector.dart';
import 'package:consultation_app/utils/validator.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Constants is initialized here because setServerUrl() must run
  // before any service that depends on the base URL is first accessed
  getIt.registerLazySingleton<Constants>(() {
    final constants = Constants();
    return constants;
  });

  getIt.registerLazySingleton<NavigationService>(() => NavigationService());
  getIt.registerLazySingleton<ApiService>(() => ApiService());
  getIt.registerLazySingleton<UserPreferences>(() => UserPreferences());

  // Stores sensitive data (tokens, credentials) in the platform's secure storage
  getIt.registerLazySingleton<SecureUserStorage>(() => SecureUserStorage());

  getIt.registerLazySingleton<NotifyUserUtils>(() => NotifyUserUtils());
  getIt.registerLazySingleton<HelperFunctions>(() => HelperFunctions());
  getIt.registerLazySingleton<Validator>(() => Validator());
  getIt.registerLazySingleton<SvgBuilder>(() => SvgBuilder());
  getIt.registerLazySingleton<ThemeSelector>(() => ThemeSelector());
  getIt.registerLazySingleton<SessionManager>(() => SessionManager());
}

// Top-level getters provide shorthand access to registered singletons
// without needing to call getIt<T>() directly throughout the codebase.
NavigationService get nav => getIt<NavigationService>();
ApiService get api => getIt<ApiService>();
UserPreferences get prefs => getIt<UserPreferences>();

// Separate from UserPreferences — backed by flutter_secure_storage
// for data that must not be stored in plain SharedPreferences
SecureUserStorage get securePrefs => getIt<SecureUserStorage>();

Constants get constants => getIt<Constants>();
NotifyUserUtils get notify => getIt<NotifyUserUtils>();
HelperFunctions get helpers => getIt<HelperFunctions>();
Validator get validator => getIt<Validator>();
SvgBuilder get svgs => getIt<SvgBuilder>();
ThemeSelector get themeSelector => getIt<ThemeSelector>();
SessionManager get sm => getIt<SessionManager>();
