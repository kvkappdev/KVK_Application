import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/router.gr.dart';
import 'package:kvk_app/services/navBar_Service.dart';
import 'package:kvk_app/services/posts_service.dart';
import 'package:kvk_app/services/profile_service.dart';
import 'package:kvk_app/services/internal_profile_service.dart';
import 'package:kvk_app/ui/templates/kvk_viewmodel.dart';
import 'package:stacked_services/stacked_services.dart';

class EditProfileViewModel extends KVKViewModel {
  final InternalProfileService _internalProfileService =
      locator<InternalProfileService>();
  final ProfileService _profileService = locator<ProfileService>();
  final NavigationService _navigationService = locator<NavigationService>();

  ImagePicker imagePicker = new ImagePicker();
  PickedFile _image;
  bool _isImageChanged = false;
  bool _isNameChanged = false;
  bool _errorVisible = false;

  bool hasProfileChanged() {
    if (_isImageChanged || _isNameChanged) {
      return true;
    }
    return false;
  }

  void navigateToNewNumberRegistration() {
    _navigationService.navigateTo(Routes.changeNumberView);
  }

  void updateProfile(BuildContext context) {
    _profileService.update(context);
  }

  void updateProfileName(BuildContext context) {
    _profileService.updateOnlyName(context);
  }

  void setErrorVisible(bool errorVisible) {
    _errorVisible = errorVisible;
  }

  bool getErrorVisible() {
    return _errorVisible;
  }

  bool getIsNameChanged() {
    return _isNameChanged;
  }

  void setName(String input) {
    _isNameChanged = true;
    _profileService.setName(input);
  }

  String getName() {
    if (_isNameChanged == true) {
      return _profileService.getName();
    }
    return _internalProfileService.getName();
  }

  bool getIsImageChanged() {
    return _isImageChanged;
  }

  void setPic(PickedFile input) {
    _profileService.setPic(input);
  }

  String getPic() {
    return _profileService.getPic().path;
  }

  void removePic() {
    _profileService.removePic();
    _isImageChanged = true;
  }

  Image getProfilePic() {
    return _internalProfileService.getProfilePic();
  }

  bool checkDefaultPic() {
    if (_isImageChanged) {
      if (_profileService.getPic() != null) {
        return false;
      } else {
        return true;
      }
    } else {
      if (_internalProfileService.getPictureURL() == "default") {
        return true;
      } else {
        return false;
      }
    }
  }

  /// Creates an image picker, and allows the user to take a photo. Then sets the photo as image.
  ///
  /// param:
  /// returns:
  /// Initial creation: 10/09/2020
  /// Last Updated: 10/09/2020
  void imgFromCamera() async {
    PickedFile image = await imagePicker.getImage(
        source: ImageSource.camera, imageQuality: 50);
    if (image != null) {
      _image = image;
      removePic();
      setPic(_image);
      _isImageChanged = true;
      rebuild();
    }
  }

  /// Creates an image picker, and allows the user to pick a photo from their library
  /// Then sets the photo as image.
  ///
  /// param:
  /// returns:
  /// Initial creation: 10/09/2020
  /// Last Updated: 10/09/2020
  void imgFromGallery() async {
    PickedFile image = await imagePicker.getImage(
        source: ImageSource.gallery, imageQuality: 50);
    if (image != null) {
      _image = image;
      removePic();
      setPic(_image);
      _isImageChanged = true;
      rebuild();
    }
  }

  Future<bool> onBackPressed() async {
    NavBarService _navBarService = locator<NavBarService>();
    _navBarService.setCurrentIndex(2);
    await _navigationService
        .pushNamedAndRemoveUntil(Routes.profileView)
        .whenComplete(() {
      return true;
    });
    return false;
  }
}
