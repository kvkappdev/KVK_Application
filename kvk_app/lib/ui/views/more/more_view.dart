import 'package:flutter/material.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/app/router.gr.dart';
import 'package:kvk_app/services/internal_profile_service.dart';
import 'package:kvk_app/ui/coloursheet.dart';
import 'package:kvk_app/ui/smart_widgets/logos/logos.dart';
import 'package:kvk_app/ui/smart_widgets/navBar/navBar.dart';
import 'package:kvk_app/ui/smart_widgets/screen_arguments.dart';
import 'package:kvk_app/ui/templates/kvk_plain_background.dart';
import 'package:kvk_app/ui/templates/kvk_box.dart';
import 'package:kvk_app/ui/viewmodels/more/more_viewmodel.dart';
import 'package:stacked/stacked.dart';

final log = getLogger("More");

class MoreView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final ScreenArguments screenArguments =
        ModalRoute.of(context).settings.arguments;

    final InternalProfileService _internalProfileService =
        locator<InternalProfileService>();

    return ViewModelBuilder<MoreViewModel>.reactive(
        builder: (context, model, child) => WillPopScope(
              onWillPop: () {
                return model.onBackPressed();
              },
              child: Scaffold(
                body: Stack(
                  children: <Widget>[
                    CustomPaint(
                      painter: PlainBackground(),
                      size: Size(screenWidth, screenHeight),
                    ),
                    CustomPaint(
                      painter: Box(0, 0.125, colour: Colour.kvk_white),
                      size: Size(screenWidth, screenHeight),
                    ),
                    Logos(),
                    Container(
                      margin: new EdgeInsets.only(top: screenHeight * 0.125),
                      child: Column(
                        children: <Widget>[
                          Visibility(
                              visible: model.isAdmin(),
                              child: menuButton(
                                width: screenWidth,
                                buttonLabel: model.lang().moreButtons[0],
                                buttonBehaviour: () {
                                  model.administrator();
                                },
                                suffixFeature: Icon(
                                  Icons.keyboard_arrow_right,
                                  color: Colour.kvk_grey,
                                ),
                              )),
                          menuButton(
                            width: screenWidth,
                            buttonLabel: model.lang().moreButtons[1],
                            buttonBehaviour: () {
                              model.dataJustice();
                            },
                            suffixFeature: Icon(
                              Icons.keyboard_arrow_right,
                              color: Colour.kvk_grey,
                            ),
                          ),
                          menuButton(
                            width: screenWidth,
                            buttonLabel: model.lang().moreButtons[2],
                            buttonBehaviour: null,
                            suffixFeature: toggleButton(model: model),
                          ),
                          menuButton(
                            width: screenWidth,
                            buttonLabel: model.lang().moreButtons[3],
                            buttonBehaviour: null,
                            suffixFeature: dropDownButton(model),
                          ),
                          model.userLoggedIn()
                              ? menuButton(
                                  width: screenWidth,
                                  buttonLabel:
                                      model.lang().moreButtons[5].toUpperCase(),
                                  buttonBehaviour: () async {
                                    _confirmLogoutDialog(context, model);
                                  },
                                  colour: Colour.kvk_error_red,
                                )
                              : menuButton(
                                  width: screenWidth,
                                  buttonLabel:
                                      model.lang().moreButtons[4].toUpperCase(),
                                  buttonBehaviour: () {
                                    model.login();
                                    model.rebuild();
                                  },
                                  colour: Colour.kvk_orange,
                                ),
                        ],
                      ),
                    )
                  ],
                ),
                bottomNavigationBar: KVKBottomNavBar(
                  routeFrom: Routes.moreView,
                  model: model,
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                floatingActionButton: KVKPostNavButton(
                    routeFrom: Routes.moreView,
                    isBasicUser: _internalProfileService.getRole() < 1,
                    screenWidth: screenWidth),
              ),
            ),
        viewModelBuilder: () => MoreViewModel());
  }
}

Widget menuButton(
    {@required double width,
    @required String buttonLabel,
    @required Function buttonBehaviour,
    Color colour = Colour.kvk_black,
    Widget suffixFeature}) {
  return Container(
    width: width,
    padding: new EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
        border:
            Border(bottom: BorderSide(color: Colour.kvk_nav_grey, width: 2))),
    child: FlatButton(
      onPressed: buttonBehaviour,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            buttonLabel,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: colour,
              fontFamily: "Lato",
              fontSize: 16,
              height: 1.3,
              fontWeight: FontWeight.w400,
            ),
          ),
          suffixFeature != null ? suffixFeature : Container(),
        ],
      ),
    ),
  );
}

_confirmLogoutDialog(BuildContext context, MoreViewModel model) {
  // set up the buttons
  Widget cancelButton = FlatButton(
    child: Text(model.lang().logoutDialog[0],
        style: TextStyle(fontFamily: "Lato", color: Colour.kvk_orange)),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  Widget continueButton = FlatButton(
    child: Text(model.lang().logoutDialog[1],
        style: TextStyle(fontFamily: "Lato", color: Colour.kvk_orange)),
    onPressed: () async {
      await model.logout();
      model.rebuild();
      Navigator.of(context).pop();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(
      model.lang().logoutDialog[2],
      style: TextStyle(fontFamily: "Lato", fontWeight: FontWeight.w700),
    ),
    content: Text(model.lang().logoutDialog[3],
        style: TextStyle(fontFamily: "Lato")),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

Widget toggleButton({@required MoreViewModel model}) {
  return InkWell(
    onTap: () {
      model.toggle();
      model.rebuild();
    },
    child: AnimatedContainer(
      duration: Duration(milliseconds: 200),
      height: 30,
      width: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: model.getToggleValue() ? Colour.kvk_orange : Colour.kvk_nav_grey,
      ),
      child: Stack(
        children: <Widget>[
          AnimatedPositioned(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 200),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return RotationTransition(
                  turns: animation,
                  child: child,
                );
              },
              child: Icon(
                Icons.brightness_1,
                color: Colour.kvk_white,
                size: 24,
                key: UniqueKey(),
              ),
            ),
            duration: Duration(milliseconds: 200),
            curve: Curves.easeIn,
            top: 3,
            left: model.getToggleValue() ? 30.0 : 0.0,
            right: model.getToggleValue() ? 0.0 : 30.0,
          )
        ],
      ),
    ),
  );
}

Widget dropDownButton(MoreViewModel model) {
  return DropdownButtonHideUnderline(
    child: DropdownButton(
      value: model.langVal(),
      onChanged: (int value) {
        model.setLang(value);
        model.changeLanguage();
      },
      iconEnabledColor: Colour.kvk_orange,
      style: TextStyle(color: Colour.kvk_black),
      selectedItemBuilder: (BuildContext context) {
        return model.getOptions().map((String value) {
          return Text(
            model.getOptions()[model.langVal()],
            style: TextStyle(color: Colour.kvk_orange, height: 2.5),
          );
        }).toList();
      },
      items: model.getOptions().map<DropdownMenuItem<int>>((String value) {
        return DropdownMenuItem<int>(
          value: model.getOptions().indexOf(value),
          child: Text(value),
        );
      }).toList(),
    ),
  );
}
