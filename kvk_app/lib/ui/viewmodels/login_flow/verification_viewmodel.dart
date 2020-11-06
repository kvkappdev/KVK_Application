import 'package:flutter/material.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/app/router.gr.dart';
import 'package:kvk_app/services/authentication_service.dart';
import 'package:kvk_app/services/navBar_Service.dart';
import 'package:kvk_app/ui/templates/kvk_viewmodel.dart';
import 'package:stacked_services/stacked_services.dart';

final log = getLogger('Verification');

class VerificationViewModel extends KVKViewModel {
  final AuthenticationService authenticationService =
      locator<AuthenticationService>();
  //0 = india, 1 = aus
  int callingCode = 0;
  int _dropDownValue = 0;
  bool _errorVisible = false;

  void setErrorVisible(bool value) {
    _errorVisible = value;
  }

  bool getErrorVisible() {
    return _errorVisible;
  }

  void setDropDownValue(int value) {
    _dropDownValue = value;
  }

  int getDropDownValue() {
    return _dropDownValue;
  }

  void setCallingCode(int value) {
    callingCode = value;
  }

  String getCallingCode() {
    if (callingCode == 0) {
      return "+91";
    } else {
      return "+61";
    }
  }

  /// Authenticate the user
  ///
  /// param: String[mobile], BuildContext[context]
  /// returns: Future
  /// Initial creation: 5/09/2020
  /// Last Updated: 5/09/2020
  Future authenticate(String mobile, BuildContext context) async {
    try {
      authenticationService.signUpWithMobile(mobile: mobile, context: context);
    } catch (e) {
      log.e("Catch" + e);
    }
  }

  bool validate(String mobile) {
    if (callingCode == 0) {
      //India Validation
      if (mobile.length >= 10 || mobile.length <= 11) {
        if ((mobile.length == 11 && mobile.substring(0, 1) == '0') ||
            mobile.length == 10) {
          return true;
        }
      }
    } else {
      //Australia Validation
      if (mobile.length >= 9 || mobile.length <= 10) {
        if ((mobile.length == 10 && mobile.substring(0, 1) == '0') ||
            mobile.length == 9) {
          return true;
        }
      }
    }
    return false;
  }

  String clean(String mobile) {
    if (callingCode == 0) {
      //India Validation
      if (mobile.length == 11) {
        return mobile.substring(1);
      }
    } else {
      //Australia Validation
      if (mobile.length == 10) {
        return mobile.substring(1);
      }
    }
    return mobile;
  }

  final NavigationService _navigationService = locator<NavigationService>();
  Future<bool> onBackPressed() async {
    final NavBarService _kvkNavBarService = locator<NavBarService>();
    _kvkNavBarService.setCurrentIndex(0);
    await _navigationService.navigateTo(Routes.homeView).whenComplete(() {
      return true;
    });
    return false;
  }
}
