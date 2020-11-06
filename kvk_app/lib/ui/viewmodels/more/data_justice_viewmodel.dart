import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/router.gr.dart';
import 'package:kvk_app/services/navBar_Service.dart';
import 'package:kvk_app/ui/smart_widgets/screen_arguments.dart';
import 'package:kvk_app/ui/templates/kvk_viewmodel.dart';
import 'package:stacked_services/stacked_services.dart';


class DataJusticeViewModel extends KVKViewModel {

  NavigationService _navigationService = locator<NavigationService>();

   Future<bool> onBackPressed() async {
    NavBarService _navBarService = locator<NavBarService>();
    _navBarService.setCurrentIndex(3);
    await _navigationService
        .pushNamedAndRemoveUntil(Routes.moreView, arguments: ScreenArguments(routeFrom: Routes.moreView))
        .whenComplete(() {
      return true;
    });
    return false;
  }

}
