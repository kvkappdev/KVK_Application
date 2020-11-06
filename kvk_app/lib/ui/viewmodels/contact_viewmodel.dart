import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/router.gr.dart';

import 'package:kvk_app/ui/templates/kvk_viewmodel.dart';
import 'package:stacked_services/stacked_services.dart';

class ContactViewModel extends KVKViewModel {
  final NavigationService _navigationService = locator<NavigationService>();

 Future<bool> onBackPressed() async {
    await _navigationService
        .pushNamedAndRemoveUntil(Routes.homeView)
        .whenComplete(() {
      return true;
    });
    return false;
  }
}
