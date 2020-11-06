import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/app/router.gr.dart';
import 'package:kvk_app/ui/coloursheet.dart';
import 'package:logger/logger.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:kvk_app/app/locator.dart';

final log = getLogger('Main');

/// Start the app
///
/// param:
/// returns:
/// Initial creation: 22/08/2020
/// Last Updated: 5/09/2020
void main() {
  Logger.level = Level.verbose;
  setupLocator();
  log.i("App is starting");
  runApp(MyApp());
  log.i("App has successfully completed startup");
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Listener(
        onPointerDown: (_) {
          FocusManager.instance.primaryFocus.unfocus();
        },
        child: MaterialApp(
          theme: ThemeData(
            textSelectionHandleColor: Colors.transparent,
            primaryColor: Colour.kvk_orange,
            accentColor: Colour.kvk_background_green,
            cursorColor: Colour.kvk_orange,
          ),
          debugShowCheckedModeBanner: false,
          initialRoute: Routes.splashScreen,
          onGenerateRoute: Router().onGenerateRoute,
          navigatorKey: locator<NavigationService>().navigatorKey,
          title: 'Flutter Demo',
        ));
  }
}
