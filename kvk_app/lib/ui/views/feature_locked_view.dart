import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/router.gr.dart';
import 'package:kvk_app/icons/kvk_icons.dart';
import 'package:kvk_app/ui/coloursheet.dart';
import 'package:kvk_app/ui/smart_widgets/backButtonResizable.dart';
import 'package:kvk_app/ui/smart_widgets/button.dart';
import 'package:kvk_app/ui/smart_widgets/screen_arguments.dart';
import 'package:kvk_app/ui/templates/kvk_plain_background.dart';
import 'package:kvk_app/ui/templates/kvk_box.dart';
import 'package:kvk_app/ui/viewmodels/feature_locked_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class FeatureLockedView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final NavigationService _navigationService = locator<NavigationService>();

    final ScreenArguments screenArguments =
        ModalRoute.of(context).settings.arguments;
    return ViewModelBuilder<FeatureLockedViewModel>.reactive(
        builder: (context, model, child) => WillPopScope(
              onWillPop: () {
                return model.onBackPressed(args: screenArguments);
              },
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                body: Stack(
                  children: <Widget>[
                    CustomPaint(
                      painter: PlainBackground(),
                      size: Size(screenWidth, screenHeight),
                    ),
                    CustomPaint(
                      painter: Box(0, 0.125),
                      size: Size(screenWidth, screenHeight),
                    ),
                    Container(
                      height: screenHeight * 0.15,
                      child: Row(
                        children: <Widget>[
                          backButton(
                              args: screenArguments,
                              width: screenWidth,
                              model: model),
                          Container(
                            margin:
                                new EdgeInsets.only(top: screenHeight * 0.025),
                            child: Text(
                              model.lang().featureLockedMessages[0],
                              style: TextStyle(
                                  color: Colour.kvk_white, fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.lock_outline,
                              size: 100,
                              color: Colour.kvk_dark_grey,
                            ),
                            Container(
                              padding: new EdgeInsets.only(top: 20),
                              child: Text(
                                model.lang().featureLockedMessages[0],
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                            ),
                            Container(
                              padding: new EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              child: model.getIsLoggedIn()
                                  ? Text(
                                      model.lang().featureLockedMessages[4],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: "Lato",
                                        color: Colour.kvk_dark_grey,
                                        fontSize: 14,
                                      ),
                                    )
                                  : RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                          style: TextStyle(
                                            fontFamily: "Lato",
                                            color: Colour.kvk_dark_grey,
                                            fontSize: 14,
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: model
                                                    .lang()
                                                    .featureLockedMessages[1]),
                                            TextSpan(
                                                text: model
                                                    .lang()
                                                    .featureLockedMessages[2],
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            TextSpan(
                                                text: model
                                                    .lang()
                                                    .featureLockedMessages[3]),
                                          ]),
                                    ),
                            ),
                            signInOrCreateButton(
                                width: screenWidth,
                                height: screenHeight,
                                onPress: () {
                                  model.getIsLoggedIn()
                                      ? _navigationService.navigateTo(
                                          Routes.registrationNameView,
                                          arguments: ScreenArguments(
                                              routeFrom:
                                                  screenArguments.routeFrom))
                                      : _navigationService.navigateTo(
                                          Routes.verificationView,
                                          arguments: ScreenArguments(
                                              routeFrom:
                                                  screenArguments.routeFrom));
                                },
                                model: model),
                          ],
                        ))
                  ],
                ),
              ),
            ),
        viewModelBuilder: () => FeatureLockedViewModel());
  }
}

Widget signInOrCreateButton(
    {@required double width,
    @required double height,
    @required Function onPress,
    @required FeatureLockedViewModel model}) {
  return Container(
    margin: new EdgeInsets.fromLTRB(20.0, height * 0.025, 20.0, 20.0),
    width: width,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(50),
    ),
    child: Button(
        text: model.getIsLoggedIn()
            ? model.lang().featureLockedMessages[5].toUpperCase()
            : model.lang().featureLockedMessages[2].toUpperCase(),
        onPress: onPress),
  );
}

Widget backButton(
    {@required double width,
    @required ScreenArguments args,
    @required FeatureLockedViewModel model}) {
  return Container(
    margin: new EdgeInsets.only(top: width * 0.05, left: width * 0),
    child: RBackButton(
      size: width * 0.1,
      color: Colour.kvk_white,
      onPressed: () async {
        model.onBackPressed(args: args);
      },
    ),
  );
}
