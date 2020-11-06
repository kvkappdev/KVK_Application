import 'package:flutter/material.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/app/router.gr.dart';
import 'package:kvk_app/services/internal_profile_service.dart';
import 'package:kvk_app/services/posts_service.dart';
import 'package:kvk_app/ui/smart_widgets/screen_arguments.dart';
import 'package:stacked_services/stacked_services.dart';

int _currentIndex = 0;
final log = getLogger('Nav-Bar');
final NavigationService _navigationService = locator<NavigationService>();
final InternalProfileService _internalProfileService =
    locator<InternalProfileService>();
final PostsService _postsService = locator<PostsService>();

class NavBarService {
  int getCurrentIndex() {
    log.d("Getting Current Index");
    return _currentIndex;
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
  }

  void bottomNavigation({@required int index, @required String routeFrom}) {
    log.d("BottomNavigationCall " + index.toString());
    if (_currentIndex != index) {
      switch (index) {
        case 0:
          {
            _navigationService.navigateTo(Routes.homeView);
          }
          break;
        case 1:
          {
            _navigationService.navigateTo(Routes.forumView);
          }
          break;
        case 2:
          {
            if (!_internalProfileService.getIsLoggedIn() ||
                !_internalProfileService.getHasProfile()) {
              _navigationService.navigateTo(Routes.featureLockedView,
                  arguments: ScreenArguments(routeFrom: routeFrom));
            } else {
              _navigationService.navigateTo(Routes.profileView);
            }
          }
          break;
        case 3:
          {
            _navigationService.navigateTo(Routes.moreView,
                arguments: ScreenArguments(routeFrom: routeFrom));
          }
          break;
      }
      setCurrentIndex(index);
    }
  }

  void post({@required String routeFrom}) {
    log.d(routeFrom);
    if (!_internalProfileService.getIsLoggedIn() ||
        !_internalProfileService.getHasProfile()) {
      //Feature Locked Page
      _navigationService.navigateTo(Routes.featureLockedView,
          arguments: ScreenArguments(routeFrom: routeFrom));
    } else {
      log.i("Create post button selected. Navigating to appropriate page...");
      _navigationService.navigateTo(Routes.createPostView,
          arguments: ScreenArguments(routeFrom: routeFrom));
    }
  }

  void announcement({@required String routeFrom}){
    _navigationService.navigateTo(Routes.createAnnouncementView,
          arguments: ScreenArguments(routeFrom: routeFrom));
  }
}
