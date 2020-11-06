import 'package:flutter/material.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/router.gr.dart';
import 'package:kvk_app/services/language_service.dart';
import 'package:kvk_app/ui/smart_widgets/screen_arguments.dart';
import 'package:kvk_app/ui/text_interface.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

/// This is the base viewModel for the entire KVK Applciation. It grants all pages the functionality
/// of languages.
///
/// param:
/// returns:
/// Initial creation: 12/09/2020
/// Last Updated: 12/09/2020
class KVKViewModel extends BaseViewModel {
  final LanguageService _languageService = locator<LanguageService>();
  final NavigationService _navigationService = locator<NavigationService>();

  TextInterface language;

  KVKViewModel() {
    language = _languageService.getLanguage();
  }

  void changeLanguage() {
    language = _languageService.getLanguage();
    notifyListeners();
  }

  TextInterface lang() {
    return language;
  }

  int langVal() {
    return _languageService.getLanguageVal();
  }

  void setLang(int lang) {
    _languageService.setLanguage(lang);
  }

  void rebuild() {
    notifyListeners();
  }

  Future popBack() async {
    _navigationService.back();
  }

  void back({@required String routeName, ScreenArguments args}) {
    _navigationService.navigateTo(routeName, arguments: args);
  }
}
