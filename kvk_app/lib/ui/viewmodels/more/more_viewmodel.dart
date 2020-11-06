import 'package:flutter/material.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/router.gr.dart';
import 'package:kvk_app/services/authentication_service.dart';
import 'package:kvk_app/services/internal_profile_service.dart';
import 'package:kvk_app/services/navBar_Service.dart';
import 'package:kvk_app/services/posts_service.dart';
import 'package:kvk_app/ui/smart_widgets/screen_arguments.dart';
import 'package:kvk_app/ui/templates/kvk_viewmodel.dart';
import 'package:stacked_services/stacked_services.dart';

final AuthenticationService _authenticationService =
    locator<AuthenticationService>();
final NavigationService _navigationService = locator<NavigationService>();
final InternalProfileService _internalProfileService =
    locator<InternalProfileService>();
final PostsService _postsService = locator<PostsService>();

class MoreViewModel extends KVKViewModel {

  List<String> options = <String>["English", "मराठी"];

  void login() {
    _navigationService.navigateTo(Routes.verificationView,
        arguments: ScreenArguments(routeFrom: Routes.moreView));
  }

  Future logout() async {
    await _authenticationService.logoutUser();
    _internalProfileService.clearUserDetails();
    _postsService.logoutCleanUp();
  }

  bool userLoggedIn() {
    return _authenticationService.isLoggedIn();
  }

  void dataJustice() {
    _navigationService.navigateTo(Routes.dataJusticeView);
  }

  void administrator() {
    _navigationService.navigateTo(Routes.administratorView);
  }

  bool isAdmin(){
    if(_internalProfileService.getRole() == 2){
      return true;
    }
    return false;
  }

  bool getToggleValue() {
    return _internalProfileService.getNotificationStatus();
  }

  void toggle() {
    _internalProfileService.setNotificationStatus();
  }

  List<String> getOptions() {
    return options;
  }
    Future<bool> onBackPressed() async {
    NavBarService _navBarService = locator<NavBarService>();
    _navBarService.setCurrentIndex(0);
    await _navigationService.pushNamedAndRemoveUntil(Routes.homeView).whenComplete(() {
      return true;
    });
    return false;
  }
}
