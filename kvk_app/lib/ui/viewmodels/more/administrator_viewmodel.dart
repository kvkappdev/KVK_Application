import 'package:flutter/material.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/router.gr.dart';
import 'package:kvk_app/data_struct/internalUser.dart';
import 'package:kvk_app/services/database_service.dart';
import 'package:kvk_app/services/navBar_Service.dart';
import 'package:kvk_app/ui/templates/kvk_viewmodel.dart';
import 'package:stacked_services/stacked_services.dart';

class AdministratorViewModel extends KVKViewModel {
  final DatabaseService _databaseService = locator<DatabaseService>();
  final NavigationService _navigationService = locator<NavigationService>();

  List<String> options = <String>["Basic", "Scientist", "Administrator"];
  int _roleId = 0;

  int callingCode = 0;
  int _dropDownValue = 0;
  bool _errorVisible = false;
  bool _profileFound = false;
  InternalUser _user = InternalUser();

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

  Future getUserByPhoneNumber(
      {@required String mobile, @required BuildContext context}) async {
    await _databaseService
        .getUserByPhoneNumber(mobile: mobile, context: context)
        .then((user) {
      _user = user;
    });
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

  bool getProfileFound() {
    return _profileFound;
  }

  void setProfileFound(bool value) {
    _profileFound = value;
  }

  InternalUser getUser() {
    return _user;
  }

  List<String> getOptions() {
    return options;
  }

  // 0 = English, 1 = Marathi
  String getRole() {
    if (_roleId == 0) {
      return "Basic";
    } else if (_roleId == 1) {
      return "Scientist";
    } else if (_roleId == 2) {
      return "Admin";
    } else {
      return "Unknown";
    }
  }

  void changeRole() {
    getRole();
    notifyListeners();
  }

  int getRoleId() {
    return _roleId;
  }

  void setRoleId(int value) {
    _roleId = value;
  }

  Future updateRole(
      {@required String userId,
      @required int role,
      @required BuildContext context}) async {
    await _databaseService
        .updateRole(context: context, databaseID: userId, role: role)
        .whenComplete(() {
          
      _user = new InternalUser();
      setProfileFound(false);
    });
  }

  Future<bool> onBackPressed() async {
    NavBarService _navBarService = locator<NavBarService>();
    _navBarService.setCurrentIndex(3);
    await _navigationService.pushNamedAndRemoveUntil(Routes.moreView).whenComplete(() {
      return true;
    });
    return false;
  }
}
