import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:kvk_app/services/posts_service.dart';
import 'package:kvk_app/services/profile_service.dart';
import 'package:kvk_app/services/database_service.dart';
import 'package:kvk_app/services/navBar_Service.dart';
import 'package:kvk_app/services/authentication_service.dart';
import 'package:kvk_app/services/language_service.dart';
import 'package:kvk_app/services/internal_profile_service.dart';
import 'package:kvk_app/services/topic_service.dart';
import 'package:kvk_app/services/pushNotification_service.dart';
// Important. Import the locator.config.dart file
import 'locator.config.dart';

final locator = GetIt.instance;

@injectableInit
void setupLocator() => {
      $initGetIt(locator),
      locator.registerLazySingleton(() => AuthenticationService()),
      locator.registerLazySingleton(() => DatabaseService()),
      locator.registerLazySingleton(() => ProfileService()),
      locator.registerLazySingleton(() => LanguageService()),
      locator.registerLazySingleton(() => InternalProfileService()),
      locator.registerLazySingleton(() => NavBarService()),
      locator.registerLazySingleton(() => PostsService()),
      locator.registerLazySingleton(() => TopicService()),
      locator.registerLazySingleton(() => PushNotificationService())
    };
