import 'package:consultation_app/services/api_service.dart';
import 'package:consultation_app/services/navigation_service.dart';
import 'package:consultation_app/services/user_preferences.dart';
import 'package:consultation_app/utils/constants.dart';
import 'package:consultation_app/utils/helper_functions.dart';
import 'package:consultation_app/utils/notify_user_utils.dart';
import 'package:consultation_app/utils/validator.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;
void setupDependencies() {
  getIt.registerLazySingleton<Constants>(() {
    final constants = Constants();
    constants.setServerUrl();
    return constants;
  });
  getIt.registerLazySingleton<NavigationService>(() => NavigationService());
  getIt.registerLazySingleton<ApiService>(() => ApiService());
  getIt.registerLazySingleton<UserPreferences>(() => UserPreferences());
  getIt.registerLazySingleton<NotifyUserUtils>(() => NotifyUserUtils());
  getIt.registerLazySingleton<HelperFunctions>(() => HelperFunctions());
  getIt.registerLazySingleton<Validator>(() => Validator());
}

NavigationService get nav => getIt<NavigationService>();
ApiService get api => getIt<ApiService>();
UserPreferences get prefs => getIt<UserPreferences>();
Constants get constants => getIt<Constants>();
NotifyUserUtils get notify => getIt<NotifyUserUtils>();
HelperFunctions get helpers => getIt<HelperFunctions>();
Validator get validator => getIt<Validator>();
