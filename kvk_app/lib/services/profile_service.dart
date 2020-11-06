import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/services/authentication_service.dart';
import 'package:kvk_app/services/database_service.dart';
import 'package:kvk_app/services/internal_profile_service.dart';

class ProfileService {
  final log = getLogger("Registration Service");
  final DatabaseService _databaseService = locator<DatabaseService>();
  final AuthenticationService _authenticationService =
      locator<AuthenticationService>();
  final InternalProfileService _internalProfileService = locator<InternalProfileService>();

  String _name;
  PickedFile _pic;

  /// Setters and getters for individuals name and profile picture
  ///
  /// param: Varies
  /// returns: Varies
  /// Initial creation: 07/09/2020
  /// Last Updated: 30/09/2020
  void setName(String input) {
    _name = input;
    log.d("Name: " + _name);
  }

  void setPic(PickedFile pic) {
    _pic = pic;
    log.d("Pic: " + _pic.path);
  }

  PickedFile getPic() {
    return _pic;
  }

  void removePic() {
    _pic = null;
  }

  String getName() {
    return _name;
  }

  /// Creates the user in the database with required details
  ///
  /// param: BuildContext [context]
  /// returns:
  /// Initial creation: 23/09/2020
  /// Last Updated: 04/10/2020
  void register(BuildContext context) {
    if (_authenticationService.isLoggedIn()) {
      _databaseService.createAccount(
          uid: _authenticationService.getUser().uid,
          context: context,
          name: _name,
          profilePic: _pic,
          role: 0,
          mobile: _authenticationService.getUser().phoneNumber);
    }
  }

  /// Creates the user in the database with required details
  ///
  /// param: BuildContext [context]
  /// returns:
  /// Initial creation: 06/10/2020
  /// Last Updated: 06/10/2020
  Future update(BuildContext context) async {
     await _databaseService.updateAccount(
          context: context,
          databaseID: _internalProfileService.getAccountDatabaseID(),
          name: _name,
          pic: _pic,);
  }

    Future updateOnlyName(BuildContext context) async{
      await _databaseService.updateAccountName(
          context: context,
          databaseID: _internalProfileService.getAccountDatabaseID(),
          name: _name,);
  }
}
