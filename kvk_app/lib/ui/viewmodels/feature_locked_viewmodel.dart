import 'package:flutter/material.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/router.gr.dart';
import 'package:kvk_app/services/internal_profile_service.dart';
import 'package:kvk_app/services/navBar_Service.dart';
import 'package:kvk_app/ui/smart_widgets/screen_arguments.dart';

import 'package:kvk_app/ui/templates/kvk_viewmodel.dart';
import 'package:stacked_services/stacked_services.dart';

class FeatureLockedViewModel extends KVKViewModel {
  final NavigationService _navigationService = locator<NavigationService>();
  final InternalProfileService _internalProfileService =
      locator<InternalProfileService>();

  Future<bool> onBackPressed({@required ScreenArguments args}) async {
    int routeIndex;
    switch (args.routeFrom) {
      case Routes.homeView:
        routeIndex = 0;
        break;
      case Routes.forumView:
        routeIndex = 1;
        break;
      case Routes.profileView:
        routeIndex = 2;
        break;
      case Routes.moreView:
        routeIndex = 3;
        break;
      default:
        routeIndex = -1;
    }

    final NavBarService _kvkNavBarService = locator<NavBarService>();
    if (routeIndex != -1) {
      _kvkNavBarService.setCurrentIndex(routeIndex);
    }
    if (_navigationService.navigateTo(args.routeFrom,
            arguments: args.oldArgs) !=
        null) {
      return true;
    }
    return false;
  }

  bool getIsLoggedIn() {
    if (_internalProfileService.getIsLoggedIn()) {
      return true;
    }
    return false;
  }
}
