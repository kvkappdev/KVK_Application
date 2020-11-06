import 'package:flutter/material.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/app/router.gr.dart';
import 'package:kvk_app/services/navBar_Service.dart';
import 'package:kvk_app/services/profile_service.dart';
import 'package:kvk_app/ui/templates/kvk_viewmodel.dart';
import 'package:stacked_services/stacked_services.dart';

class RegistrationNameViewModel extends KVKViewModel {
  final log = getLogger('Registration-Name-Viewmodel');
  final ProfileService _profileService =
      locator<ProfileService>();
  final NavigationService _navigationService = locator<NavigationService>();
  bool _errorVisible = false;
  

  void setErrorVisible(bool errorVisible) {
    _errorVisible = errorVisible;
  }

  bool getErrorVisible() {
    return _errorVisible;
  }

  void setName(String input) {
    _profileService.setName(input);
  }

  String getName() {
    if (_profileService.getName() != null) {
      return _profileService.getName();
    }
    return "";
  }

  void throwMissingNameError() {
    log.e("Name can't be empty");
  }


  /// Handles when the back button is pressed on this page
  /// param: 
  /// returns: 
  /// Initial creation: 08/09/2020
  /// Last Updated: 08/09/2020
  Future<bool> onBackPressed() async {
    final NavBarService _kvkNavBarService = locator<NavBarService>();
    _kvkNavBarService.setCurrentIndex(0);
    await _navigationService.navigateTo(Routes.homeView).whenComplete(() {
      return true;
    });
    return false;
  }
}
