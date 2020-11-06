import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/ui/coloursheet.dart';
import 'package:kvk_app/ui/smart_widgets/backButtonResizable.dart';
import 'package:kvk_app/ui/smart_widgets/button.dart';
import 'package:kvk_app/ui/templates/kvk_background_painter.dart';
import 'package:kvk_app/ui/templates/kvk_box.dart';
import 'package:kvk_app/ui/viewmodels/login_flow/registration_finalise_viewmodel.dart';
import 'package:stacked/stacked.dart';

final log = getLogger('Registration-Finalise-View');

class RegistrationFinaliseView extends StatelessWidget {
  /// Display the finalised registration view
  ///
  /// param: BuildContext[context]
  /// returns: Widget
  /// Initial creation: 21/09/2020
  /// Last Updated: 21/09/2020
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return ViewModelBuilder<RegistrationFinaliseViewModel>.reactive(
      builder: (context, model, child) => WillPopScope(
        onWillPop: model.onBackPressed,
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              CustomPaint(
                painter: BackgroundPainter(),
                size: Size(screenWidth, MediaQuery.of(context).size.height),
              ),
              CustomPaint(
                painter: Box(0, 0.3),
                size: Size(screenWidth, MediaQuery.of(context).size.height),
              ),
              backButton(width: screenWidth),
              finaliseTitle(
                  width: screenWidth, height: screenHeight, model: model),
              finaliseMsg(
                  width: screenWidth, height: screenHeight, model: model),
              Container(
                margin: new EdgeInsets.only(top: screenHeight * 0.35),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    nameLabel(
                        width: screenWidth, height: screenHeight, model: model),
                    nameValue(
                        width: screenWidth, height: screenHeight, model: model),
                    picLabel(
                        width: screenWidth, height: screenHeight, model: model),
                    Container(
                      alignment: Alignment.center,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: <Widget>[
                          picDisplay(model: model, width: screenWidth),
                          inputAction(model: model, width: screenWidth),
                        ],
                      ),
                    ),
                    registerButton(
                      width: screenWidth,
                      height: screenHeight,
                      model: model,
                      context: context,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      viewModelBuilder: () => RegistrationFinaliseViewModel(),
    );
  }

  /// Addss a back button at the top left of the page
  /// param: double [width]
  /// returns: Container
  /// Initial creation: 29/09/2020
  /// Last Updated: 29/09/2020
  Widget backButton({@required double width}) {
    return Container(
      margin: new EdgeInsets.only(top: width * 0.05, left: width * 0),
      child: RBackButton(
        size: width * 0.1,
        color: Colour.kvk_white,
      ),
    );
  }

  /// Creates the title for the page
  /// param: double [width], double [height]
  /// returns: Container
  /// Initial creation: 21/09/2020
  /// Last Updated: 21/09/2020
  Widget finaliseTitle(
      {@required RegistrationFinaliseViewModel model,
      @required double width,
      @required double height}) {
    return Container(
      margin: new EdgeInsets.only(top: height * 0.2, left: width * 0.05),
      child: Text(
        model.lang().registrationFinaliseTitle,
        style: TextStyle(
            color: Colour.kvk_white,
            fontFamily: "Lato",
            fontSize: 24,
            height: 1.2,
            fontWeight: FontWeight.w700),
      ),
    );
  }

  /// Creates the message for the page
  /// param: double [width], double [height]
  /// returns: Container
  /// Initial creation: 21/09/2020
  /// Last Updated: 21/09/2020
  Widget finaliseMsg(
      {@required double width,
      @required double height,
      @required RegistrationFinaliseViewModel model}) {
    return Container(
      margin: new EdgeInsets.only(top: height * 0.25, left: width * 0.05),
      child: Text(
        model.lang().registrationFinaliseMsg,
        style: TextStyle(
            color: Colour.kvk_white,
            fontFamily: "Lato",
            fontSize: 14,
            height: 1.4,
            fontWeight: FontWeight.w400),
      ),
    );
  }

  /// Creates the label with text name
  /// param: double [width], double [height]
  /// returns: Container
  /// Initial creation: 21/09/2020
  /// Last Updated: 21/09/2020
  Widget nameLabel(
      {@required double width,
      @required double height,
      @required RegistrationFinaliseViewModel model}) {
    return Container(
      margin: new EdgeInsets.only(left: width * 0.1),
      child: Text(
        model.lang().name,
        style: TextStyle(
            color: Colour.kvk_black,
            fontFamily: "Lato",
            fontSize: 18,
            height: 1.2,
            fontWeight: FontWeight.w400),
      ),
    );
  }

  /// Creates the TextFormField that holds the users name. This can not be edited here
  /// Clicking on this will take you back to the name page
  /// param: double [width], double [height], RegistrationFinaliseViewModel [model]
  /// returns: Container
  /// Initial creation: 21/09/2020
  /// Last Updated: 21/09/2020
  Widget nameValue(
      {@required double width,
      @required double height,
      @required RegistrationFinaliseViewModel model}) {
    return Container(
      margin: new EdgeInsets.only(left: width * 0.13, right: width * 0.13),
      padding: new EdgeInsets.only(bottom: height * 0.05),
      child: TextFormField(
        decoration: InputDecoration(
          suffixIcon: Icon(
            Icons.swap_horizontal_circle,
            color: Colour.kvk_orange,
          ),
        ),
        initialValue: model.getName(),
        readOnly: true,
        enableInteractiveSelection: false,
        style: TextStyle(
            color: Colour.kvk_black,
            fontFamily: "Lato",
            fontSize: 14,
            height: 1.4,
            fontWeight: FontWeight.w400),
        onTap: () => model.changeName(),
      ),
    );
  }

  /// Creates the label with text Profile Picture
  /// param: double [width], double [height]
  /// returns: Container
  /// Initial creation: 21/09/2020
  /// Last Updated: 21/09/2020
  Widget picLabel(
      {@required RegistrationFinaliseViewModel model,
      @required double width,
      @required double height}) {
    return Container(
      margin: new EdgeInsets.only(left: width * 0.1),
      padding: new EdgeInsets.only(bottom: height * 0.02),
      child: Text(
        model.lang().profilePic,
        style: TextStyle(
            color: Colour.kvk_black,
            fontFamily: "Lato",
            fontSize: 18,
            height: 1.2,
            fontWeight: FontWeight.w400),
      ),
    );
  }

  /// Creates the CircleAvatar that holds the users profile picture. This can not be edited here
  /// Clicking on this will take you back to the profile pic page
  /// param: double [width], RegistrationFinaliseViewModel [model]
  /// returns: Container
  /// Initial creation: 21/09/2020
  /// Last Updated: 21/09/2020
  Widget picDisplay(
      {@required double width, @required RegistrationFinaliseViewModel model}) {
    return Container(
      child: model.checkPic()
          ? FlatButton(
              onPressed: () {
                model.changePic();
              },
              child: Container(
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    backgroundImage: FileImage(
                      File(model.getPic()),
                    ),
                    radius: width * 0.185,
                  ),
                  padding: const EdgeInsets.all(2.0),
                  decoration: new BoxDecoration(
                    border: Border.all(
                      color: Colour.kvk_dark_grey,
                    ),
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  )),
            )
          : FlatButton(
              onPressed: () {
                model.changePic();
              },
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                backgroundImage: new AssetImage(
                  "assets/img/blank_profile.png",
                ),
                radius: width * 0.185,
              ),
            ),
    );
  }

  /// Creates the icon for swap symbol that is appended to name, and added to the profile pic
  /// param: double [width], RegistrationFinaliseViewModel [model]
  /// returns: Container
  /// Initial creation: 21/09/2020
  /// Last Updated: 21/09/2020
  Widget inputAction({
    @required RegistrationFinaliseViewModel model,
    @required double width,
  }) {
    return Container(
        padding: new EdgeInsets.all(0),
        decoration:
            BoxDecoration(shape: BoxShape.circle, color: Colour.kvk_white),
        child: IconButton(
          icon: Icon(Icons.swap_horizontal_circle),
          iconSize: width * 0.1,
          color: Colour.kvk_orange,
          onPressed: () {
            model.changePic();
          },
        ));
  }

  /// Creates the register button which will trigger the registration process on tap
  /// param: double [width], double [height], RegistrationFinaliseViewModel [model], BuildContext [context]
  /// returns: Container
  /// Initial creation: 21/09/2020
  /// Last Updated: 21/09/2020
  Widget registerButton(
      {@required double width,
      @required double height,
      @required RegistrationFinaliseViewModel model,
      @required BuildContext context}) {
    return Container(
      alignment: Alignment.center,
      padding: new EdgeInsets.only(top: height * 0.02),
      child: Button(
        text: model.lang().register.toUpperCase(),
        onPress: () {
          model.register(context);
        },
        width: width * 0.6,
      ),
    );
  }
}
