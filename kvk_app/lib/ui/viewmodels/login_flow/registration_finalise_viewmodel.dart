import 'package:flutter/cupertino.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/app/router.gr.dart';
import 'package:kvk_app/services/profile_service.dart';
import 'package:kvk_app/ui/smart_widgets/screen_arguments.dart';
import 'package:kvk_app/ui/templates/kvk_viewmodel.dart';
import 'package:stacked_services/stacked_services.dart';

class RegistrationFinaliseViewModel extends KVKViewModel {
  final log = getLogger('Registration-Final-Viewmodel');
  final ProfileService _profileService = locator<ProfileService>();
  final NavigationService _navigationService = locator<NavigationService>();

  String getName() {
    return _profileService.getName();
  }

  String getPic() {
    return _profileService.getPic().path;
  }

  /// Determines if the user has a profile picture or not
  /// param:
  /// returns: boolean
  /// Initial creation: 21/09/2020
  /// Last Updated: 21/09/2020
  bool checkPic() {
    if (_profileService.getPic() != null) {
      return true;
    }
    return false;
  }

  /// Registers the user adding their information to the database
  /// param: BuildContext [context]
  /// returns:
  /// Initial creation: 21/09/2020
  /// Last Updated: 21/09/2020
  void register(BuildContext context) {
    _profileService.register(context);
  }

  /// Navigates the user back to the profile pic registration page
  /// param:
  /// returns:
  /// Initial creation: 21/09/2020
  /// Last Updated: 21/09/2020
  void changePic() {
    _navigationService.navigateTo(Routes.registrationPicView);
  }

  /// Navigates the user back to the name registration page. This is passed with the finalRegistrationPage
  /// argument which allows the user to return straight back to this page on completion
  ///
  /// param:
  /// returns:
  /// Initial creation: 21/09/2020
  /// Last Updated: 21/09/2020
  void changeName() {
    _navigationService.navigateTo(Routes.registrationNameView,
        arguments: ScreenArguments(routeFrom: Routes.registrationFinaliseView));
  }

  /// Forces the back button to navigate to the registration picture view if it is avaliable, else do nothing
  ///
  /// param:
  /// returns:
  /// Initial creation: 21/09/2020
  /// Last Updated: 21/09/2020
  Future<bool> onBackPressed() async {
    await _navigationService
        .navigateTo(Routes.registrationPicView)
        .whenComplete(() {
      return true;
    });
    return false;
  }
}
