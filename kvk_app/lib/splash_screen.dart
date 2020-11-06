import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/app/router.gr.dart';
import 'package:kvk_app/services/authentication_service.dart';
import 'package:kvk_app/services/database_service.dart';
import 'package:kvk_app/services/internal_profile_service.dart';
import 'package:kvk_app/services/posts_service.dart';
import 'package:kvk_app/services/topic_service.dart';
import 'package:kvk_app/services/pushNotification_service.dart';
import 'package:kvk_app/ui/coloursheet.dart';
import 'package:stacked_services/stacked_services.dart';

import 'app/locator.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final NavigationService _navigationService = locator<NavigationService>();

  final log = getLogger("Splash");
  final PushNotificationService _pushNotificationService =
      locator<PushNotificationService>();

  @override
  void initState() {
    super.initState();
    _checkForSession();
  }

  Future _checkForSession() async {
    await Firebase.initializeApp().then((value) async {
      final AuthenticationService _authenticationService =
          locator<AuthenticationService>();
      final DatabaseService _databaseService = locator<DatabaseService>();
      final InternalProfileService _internalProfileService =
          locator<InternalProfileService>();
      final PostsService _postsService = locator<PostsService>();
      final TopicService _topicService = locator<TopicService>();

      await _topicService
          .loadTopics()
          .whenComplete(() => _postsService.loadTopicPosts());

      await _pushNotificationService.initialise();

      await _postsService.getData();
      await _postsService.loadAnnouncements();
      //Is logged in
      if (_authenticationService.isLoggedIn()) {
        log.d("Logged In");
        _internalProfileService.setIsLoggedIn(true);
        User user = _authenticationService.getUser();
        await _databaseService
            .setAccountData(user)
            .catchError((error) => {
                  //TODO: Set up error dialog for if something fails
                })
            .whenComplete(() async {
          await _databaseService.profileExists().then((userExists) async {
            //This information is also in the Authentication Service login, in createDialogs - successDialogs
            if (userExists) {
              _internalProfileService.setHasProfile(true);

              await _databaseService
                  .getSubscribedPostsIDS()
                  .then((subscribedPosts) {
                _internalProfileService.setSubscribedPostsIds(subscribedPosts);
              });
              await _postsService.loadMyPosts();
              await _postsService.loadSubscribedPosts();
            } else {
              _internalProfileService.setHasProfile(false);
            }
          });
        });
      }
      //Is not logged in
      else {
        log.d("Logged Out");
        _internalProfileService.setIsLoggedIn(false);
      }
    }).whenComplete(() => _navigateToHome());
  }

  void _navigateToHome() async {
    await _navigationService.replaceWith(Routes.homeView);
  }

  //Note: This text does not need to be in the language file as the application name will always be in English
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        color: Colour.kvk_background_green,
        child: Text(
          "KVK APP",
          style: TextStyle(
              color: Colour.kvk_white, fontFamily: "Leaf", fontSize: 50),
        ),
      ),
    );
  }
}
