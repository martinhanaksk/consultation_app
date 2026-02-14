import 'package:get_it/get_it.dart';
import 'package:consultation_app/services/user_preferences.dart';
import 'package:consultation_app/utils/constants.dart';
import 'package:consultation_app/utils/helper_functions.dart';
import 'package:consultation_app/utils/notify_user_utils.dart';
import 'package:consultation_app/utils/validator.dart';

// Single global service locator instance
final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Register ALL your utilities here
  sl.registerLazySingleton(() {
    final constants = Constants();
    constants.checkIfTestingServer(false);
    return constants;
  });
  
  sl.registerLazySingleton(() => HelperFunctions());
  sl.registerLazySingleton(() => NotifyUserUtils());
  sl.registerLazySingleton(() => Validator());
  sl.registerLazySingleton(() => UserPreferences());
  
  // Add more as you need them
  // sl.registerLazySingleton(() => ApiService());
  // sl.registerLazySingleton(() => AuthRepository());
}
