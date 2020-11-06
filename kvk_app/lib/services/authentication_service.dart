import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/app/router.gr.dart';
import 'package:kvk_app/icons/kvk_icons.dart';
import 'package:kvk_app/services/language_service.dart';
import 'package:kvk_app/services/navBar_Service.dart';
import 'package:kvk_app/services/internal_profile_service.dart';
import 'package:kvk_app/services/posts_service.dart';
import 'package:kvk_app/ui/coloursheet.dart';
import 'package:kvk_app/ui/smart_widgets/alert_builder.dart';
import 'package:kvk_app/ui/text_interface.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:kvk_app/services/database_service.dart';

class AuthenticationService {
  final log = getLogger('Authentication Service');
  final DatabaseService _databaseService = locator<DatabaseService>();
  final PostsService _postsService = locator<PostsService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final LanguageService _languageService = locator<LanguageService>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final InternalProfileService _internalProfileService =
      locator<InternalProfileService>();
  final NavBarService _navBarService = locator<NavBarService>();

  AlertBuilder _logInSuccessAlert, _errorAlert, _loadingAlert;
  String _mobile, _verificationId;

  /// Verifies the mobile number of the user.
  ///
  /// param: String[mobile], BuildContext[context]
  /// returns: Future
  /// Initial creation: 5/09/2020
  /// Last Updated: 30/09/2020
  Future signUpWithMobile(
      {@required String mobile, BuildContext context}) async {
    log.d("Beginning Signup Process");
    _mobile = mobile;

    createDialogs(context);

    // Activates when timeout occurs
    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      log.w("Code Retrieval Timed Out");
      log.d("verificationId: " + verificationId);
      _verificationId = verificationId;
    };

    // Activates each time as a manual request
    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      log.d("verificationId: " + verificationId);
      _verificationId = verificationId;
      _loadingAlert.dismissDialog();
      if (!_internalProfileService.getChangeNumberRequest()) {
        _navigationService.navigateTo(Routes.verificationCodeView);
      } else {
        _navigationService.navigateTo(Routes.changeNumberCodeView);
      }
    };

    // Activates when auto-retrieval process successfully retrieves SMS code and automatically uses code to generate a credential object.
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential credential) async {
      await _firebaseAuth.signInWithCredential(credential).whenComplete(() {
        if (!_internalProfileService.getChangeNumberRequest()) {
          _loadingAlert.dismissDialog();

          _logInSuccessAlert.showDialog();
        } else {
          _internalProfileService.setChangeNumberRequest(false);
        }
      });
    };

    //Activates when verification fails, either automatically or manually
    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException e) {
      if (e.code == 'invalid-phone-number') {
        log.e("Invalid Phone Number - " + e.message);
      } else {
        log.e(e.code + ": " + e.message);
      }
      _loadingAlert.dismissDialog();
      _errorAlert.showDialog();
    };

    _loadingAlert.showDialog();

    //The actual call to firebase instance to verify the number
    _firebaseAuth
        .verifyPhoneNumber(
            phoneNumber: _mobile,
            timeout: Duration(seconds: 60),
            verificationCompleted: verificationCompleted,
            verificationFailed: verificationFailed,
            codeSent: codeSent,
            codeAutoRetrievalTimeout: codeAutoRetrievalTimeout)
        .catchError((e) {
      log.e("Verify Phone Number: " + e);
    });
  }

  /// Query the Firebase Instance to determine if a user is logged in.
  ///
  /// param:
  /// returns: bool[userLoggedIn]
  /// Initial creation: 3/09/2020
  /// Last Updated: 3/09/2020
  bool isLoggedIn() {
    bool userLoggedIn;

    if (_firebaseAuth.currentUser == null) {
      userLoggedIn = false;
    } else {
      userLoggedIn = true;
    }
    _internalProfileService.setIsLoggedIn(userLoggedIn);
    return userLoggedIn;
  }

  /// Getter for the current user.
  ///
  /// param:
  /// returns: User
  /// Initial creation: 3/09/2020
  /// Last Updated: 3/09/2020
  User getUser() {
    return _firebaseAuth.currentUser;
  }

  /// Signs the user in with the smsCode and the verification Id.
  ///
  /// param: String[verificationId]
  /// returns:
  /// Initial creation: 5/09/2020
  /// Last Updated: 5/09/2020
  Future signIn(String smsCode, BuildContext context) async {
    final AuthCredential _credential = PhoneAuthProvider.credential(
        verificationId: _verificationId, smsCode: smsCode);
    log.d("Credientials: vId - " + _verificationId + " smsCode - " + smsCode);

    _loadingAlert.showDialog();

    await _firebaseAuth.signInWithCredential(_credential).catchError((error) {
      _errorAlert.setErrorState(true);
    }).whenComplete(() async {
      if (_errorAlert.getErrorState()) {
        _loadingAlert.dismissDialog();
        _errorAlert.showDialog();
      } else if (_internalProfileService.getChangeNumberRequest()) {
        User user = this.getUser();
        _internalProfileService.setIsLoggedIn(true);
        _internalProfileService.setMobile(user.phoneNumber);

        await _databaseService.changeAccount(
            databaseID: _internalProfileService.getAccountDatabaseID(),
            uid: user.uid,
            context: context,
            mobile: _internalProfileService.getMobile());
      }
      //Standard Login Flow
      else {
        User user = this.getUser();
        _databaseService.setAccountData(user).catchError((error) {
          _errorAlert.setErrorState(true);
        }).whenComplete(() {
          if (!_errorAlert.getErrorState()) {
            _databaseService.profileExists().then((userExists) async {
              //This information is also in the Authentication Service login, in createDialogs - successDialogs
              if (userExists) {
                _internalProfileService.setHasProfile(true);

                await _databaseService
                    .getSubscribedPostsIDS()
                    .then((subscribedPosts) {
                  _internalProfileService
                      .setSubscribedPostsIds(subscribedPosts);
                });

                await _postsService.loadMyPosts();
                await _postsService.loadSubscribedPosts();
              }
            });
            _loadingAlert.dismissDialog();
            _logInSuccessAlert.showDialog();
          } else {
            _loadingAlert.dismissDialog();
            _errorAlert.showDialog();
          }
        });
      }
    });
  }

  AlertBuilder getLoadingDialog() {
    return _loadingAlert;
  }

  /// Creates the dialogs for success, error and loading
  ///
  /// param: BuildContext [context]
  /// returns:
  /// Initial creation: 23/09/2020
  /// Last Updated: 27/09/2020
  void createDialogs(BuildContext context) {
    TextInterface lang = _languageService.getLanguage();
    _logInSuccessAlert = AlertBuilder(
        context: context,
        title: lang.popupMessages[0].toUpperCase(),
        titleColour: Colour.kvk_success_green,
        message: lang.popupMessages[4],
        icon: KVKIcons.accept_original,
        iconColour: Colour.kvk_success_green,
        buttonText: lang.ok,
        onPress: () async {
          _logInSuccessAlert.dismissDialog();
          User user = this.getUser();
          _internalProfileService.setIsLoggedIn(true);

          await _databaseService.setAccountData(user);
          await _databaseService.profileExists().then((profileExists) {
            if (profileExists) {
              _navBarService.setCurrentIndex(0);
              _navigationService.navigateTo(Routes.homeView);
            } else {
              _navigationService.navigateTo(Routes.registrationNameView);
            }
          });
        });
    _logInSuccessAlert.createAlert();

    _errorAlert = AlertBuilder(
        context: context,
        title: lang.popupMessages[1].toUpperCase(),
        titleColour: Colour.kvk_error_red,
        message: lang.popupMessages[3],
        icon: KVKIcons.cancel_original,
        iconColour: Colour.kvk_error_red,
        buttonText: lang.ok,
        onPress: () async {
          _errorAlert.dismissDialog();
          _errorAlert.setErrorState(false);
        });
    _errorAlert.createAlert();

    _loadingAlert = AlertBuilder(
      context: context,
      loadingAlert: true,
      title: lang.popupMessages[2],
      titleColour: Colour.kvk_grey,
    );
    _loadingAlert.createAlert();
  }

  /// Logs the current user out of the firebase instance.
  ///
  /// param:
  /// returns:
  /// Initial creation: 5/09/2020
  /// Last Updated: 5/09/2020
  Future logoutUser() async {
    log.d("Signing out");
    await _firebaseAuth.signOut();
    _internalProfileService.setIsLoggedIn(false);
    _databaseService.setAccountData(null);
    log.d("User signed out");
  }

  String get mobile {
    return _mobile;
  }
}
