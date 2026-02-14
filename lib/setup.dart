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
    constants.checkIfTestingServer(false);
    return constants;
  });

  getIt.registerLazySingleton<HelperFunctions>(() => HelperFunctions());
  getIt.registerLazySingleton<Validator>(() => Validator());
  getIt.registerLazySingleton<NotifyUserUtils>(() => NotifyUserUtils());
  getIt.registerLazySingleton<UserPreferences>(() => UserPreferences());
}
