import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/app/router.gr.dart';
import 'package:kvk_app/services/profile_service.dart';
import 'package:kvk_app/ui/templates/kvk_viewmodel.dart';
import 'package:stacked_services/stacked_services.dart';

class RegistrationPicViewModel extends KVKViewModel {
  final log = getLogger('Registration-Pic-View-Model');
  final ProfileService _profileService = locator<ProfileService>();
  final NavigationService _navigationService = locator<NavigationService>();

  ImagePicker imagePicker = new ImagePicker();
  PickedFile _image;

  void setPic(PickedFile input) {
    _profileService.setPic(input);
  }

  bool checkPic() {
    if (_profileService.getPic() != null) {
      return true;
    }
    return false;
  }

  String getPic() {
    return _profileService.getPic().path;
  }

  void next() {
    _navigationService.navigateTo(Routes.registrationFinaliseView);
  }

  void removePic() {
    _profileService.removePic();
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
      rebuild();
    }
  }

  /// Override the back button to always navigate to the registration name view
  ///
  /// param:
  /// returns:
  /// Initial creation: 10/09/2020
  /// Last Updated: 10/09/2020
  Future<bool> onBackPressed({@required String routeFrom}) async {
    await _navigationService.navigateTo(routeFrom).whenComplete(() {
      return true;
    });
    return false;
  }
}
