import 'package:flutter/cupertino.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/services/authentication_service.dart';
import 'package:kvk_app/services/internal_profile_service.dart';
import 'package:kvk_app/ui/templates/kvk_viewmodel.dart';
import 'package:stacked_services/stacked_services.dart';

final log = getLogger('Change-Number-Verification-Code-Viewmodel');

class ChangeNumberCodeViewmodel extends KVKViewModel {
  String _code = "";

  final AuthenticationService _authenticationService =
      locator<AuthenticationService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final InternalProfileService _internalProfileService = locator<InternalProfileService>();

  void signIn(BuildContext context) async {
    _internalProfileService.setChangeNumberRequest(true);
    await _authenticationService.signIn(_code, context);
  }

  void setCode(String code) {
    this._code = code;
  }

  String getCode() {
    return _code;
  }

  /// Navigates to the mobile page (back) in order to resend the code - this is done as per design
  ///
  /// param: 
  /// returns: 
  /// Initial creation: 8/09/2020
  /// Last Updated: 8/09/2020
  void resendCode() {
    _navigationService.back();
  }

  /// Ensures the code is of length 6
  ///
  /// param: 
  /// returns: Boolean
  /// Initial creation: 10/09/2020
  /// Last Updated: 10/09/2020
  bool validCode() {
    if (_code.length == 6) {
      return true;
    }
    return false;
  }
}
