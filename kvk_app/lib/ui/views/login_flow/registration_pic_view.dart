import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/app/router.gr.dart';
import 'package:kvk_app/icons/kvk_icons.dart';
import 'package:kvk_app/ui/coloursheet.dart';
import 'package:kvk_app/ui/smart_widgets/backButtonResizable.dart';
import 'package:kvk_app/ui/templates/kvk_background_painter.dart';
import 'package:kvk_app/ui/templates/kvk_box.dart';
import 'package:kvk_app/ui/viewmodels/login_flow/registration_pic_viewmodel.dart';
import 'package:stacked/stacked.dart';

final log = getLogger('Registration-Pic-View');

class RegistrationPicView extends StatelessWidget {
  /// Display the Registration picture view
  ///
  /// param: BuildContext[context]
  /// returns: Widget
  /// Initial creation: 8/09/2020
  /// Last Updated: 8/09/2020
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return ViewModelBuilder<RegistrationPicViewModel>.reactive(
      builder: (context, model, child) => WillPopScope(
        onWillPop: () {
          return model.onBackPressed(routeFrom: Routes.registrationNameView);
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
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
              backButton(width: screenWidth, model: model),
              registrationTitle(
                  width: screenWidth, height: screenHeight, model: model),
              registrationMsg(
                  width: screenWidth, height: screenHeight, model: model),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  inputNotice(
                      width: screenWidth, height: screenHeight, model: model),
                  Align(
                    alignment: Alignment.center,
                    child: Stack(
                        alignment: Alignment.bottomRight,
                        children: <Widget>[
                          input(
                              model: model,
                              context: context,
                              width: screenWidth),
                          inputAction(
                              model: model,
                              context: context,
                              width: screenWidth),
                        ]),
                  ),
                ],
              ),
              button(
                  context: context,
                  model: model,
                  width: screenWidth,
                  height: screenHeight),
            ],
          ),
        ),
      ),
      viewModelBuilder: () => RegistrationPicViewModel(),
    );
  }

  /// Creates the back button in the top left of the screen
  ///
  /// param: double [width], RegistrationPicViewModel [model]
  /// returns: Container
  /// Initial creation: 10/09/2020
  /// Last Updated: 10/09/2020
  Widget backButton(
      {@required double width, @required RegistrationPicViewModel model}) {
    return Container(
      margin: new EdgeInsets.only(top: width * 0.05, left: width * 0),
      child: RBackButton(
        size: width * 0.1,
        color: Colour.kvk_white,
        onPressed: () async {
          await model.onBackPressed(routeFrom: Routes.registrationNameView);
        },
      ),
    );
  }

  /// Creates the button that is either a next arrow, or skip, depending on if the user has
  /// selected a profile picture or not
  ///
  /// param:
  /// returns:
  /// Initial creation: 10/09/2020
  /// Last Updated: 10/09/2020
  Widget button(
      {@required BuildContext context,
      @required RegistrationPicViewModel model,
      @required double width,
      @required double height}) {
    return Container(
      margin: model.checkPic()
          ? (EdgeInsets.only(top: height * 0.9, left: width * 0.8))
          : (EdgeInsets.only(top: height * 0.9, left: width * 0.75)),
      child: model.checkPic()
          ? FloatingActionButton(
              backgroundColor: Colour.kvk_orange,
              child: Icon(Icons.keyboard_arrow_right),
              onPressed: () {
                model.next();
              },
            )
          : FloatingActionButton.extended(
              label: Text(model.lang().skip.toUpperCase()),
              foregroundColor: Colour.kvk_orange,
              backgroundColor: Colour.kvk_white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1, color: Colour.kvk_orange),
                  borderRadius: BorderRadius.all(Radius.circular(50))),
              onPressed: () {
                model.next();
              },
            ),
    );
  }

  /// Creates the title for the page
  ///
  /// param: double [width], double [height]
  /// returns: Container
  /// Initial creation: 10/09/2020
  /// Last Updated: 10/09/2020
  Widget registrationTitle(
      {@required RegistrationPicViewModel model,
      @required double width,
      @required double height}) {
    return Container(
      margin: new EdgeInsets.only(top: height * 0.2, left: width * 0.05),
      child: Text(
        model.lang().registrationTitle,
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
  ///
  /// param: double [width], double [height]
  /// returns: Container
  /// Initial creation: 10/09/2020
  /// Last Updated: 10/09/2020
  Widget registrationMsg(
      {@required RegistrationPicViewModel model,
      @required double width,
      @required double height}) {
    return Container(
      margin: new EdgeInsets.only(top: height * 0.25, left: width * 0.05),
      child: Text(
        model.lang().registrationMsg,
        style: TextStyle(
            color: Colour.kvk_white,
            fontFamily: "Lato",
            fontSize: 14,
            height: 1.4,
            fontWeight: FontWeight.w400),
      ),
    );
  }

  /// Creates the input at the centre of the page, with a default profile picture
  /// or profile pictuire selected by the user
  ///
  /// param: RegistrationPicViewModel [model]. BuildContext [context], double [width]
  /// returns: Container
  /// Initial creation: 10/09/2020
  /// Last Updated: 10/09/2020
  Widget input(
      {@required RegistrationPicViewModel model,
      @required BuildContext context,
      @required double width}) {
    return Container(
      child: model.checkPic()
          ? FlatButton(
              onPressed: () {
                _showPicker(context: context, model: model);
                model.rebuild();
              },
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                backgroundImage: FileImage(
                  File(model.getPic()),
                ),
                radius: width * 0.185,
              ),
            )
          : FlatButton(
              onPressed: () {
                _showPicker(context: context, model: model);
                model.rebuild();
              },
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                backgroundImage: new AssetImage(
                  "assets/img/blank_profile.png",
                ),
                radius: width * 0.185,
              ),
            ),
      padding: const EdgeInsets.all(2.0),
      decoration: new BoxDecoration(
        border: Border.all(
          color: Colour.kvk_nav_grey,
        ),
        color: Colors.transparent,
        shape: BoxShape.circle,
      ),
    );
  }

  /// Creates the plus and cross icons next to the picture, depending on if the profile picture
  /// is the default one or not
  ///
  /// param: RegistrationPicViewModel [model]. BuildContext [context], double [width]
  /// returns: Container
  /// Initial creation: 10/09/2020
  /// Last Updated: 10/09/2020
  Widget inputAction(
      {@required RegistrationPicViewModel model,
      @required BuildContext context,
      @required double width}) {
    return Container(
        child: Stack(
      children: <Widget>[
        model.checkPic()
            ? Container(
                padding: new EdgeInsets.all(0),
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: Colour.kvk_white),
                child: IconButton(
                  icon: Icon(KVKIcons.cancel_original),
                  iconSize: width * 0.1,
                  color: Colour.kvk_orange,
                  onPressed: () {
                    model.removePic();
                    model.rebuild();
                  },
                ),
              )
            : Container(
                padding: new EdgeInsets.all(0),
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: Colour.kvk_white),
                child: IconButton(
                  icon: Icon(KVKIcons.plus_original),
                  iconSize: width * 0.1,
                  color: Colour.kvk_orange,
                  onPressed: () {
                    _showPicker(context: context, model: model);
                  },
                ),
              ),
      ],
    ));
  }

  /// Creates text that is displayed
  ///
  /// param: double [width], double [height]
  /// returns: Container
  /// Initial creation: 10/09/2020
  /// Last Updated: 10/09/2020
  Widget inputNotice(
      {@required RegistrationPicViewModel model,
      @required double width,
      @required double height}) {
    return Container(
      margin: new EdgeInsets.only(top: height * 0.33, left: width * 0.08),
      padding: new EdgeInsets.only(bottom: height * 0.02),
      child: Text(
        model.lang().registrationPicMsg,
        style: TextStyle(
            color: Colour.kvk_black,
            fontFamily: "Lato",
            fontSize: 14,
            height: 1.4,
            fontWeight: FontWeight.w400),
      ),
    );
  }

  /// Creates the picker that slides up from the bottom of the page on the click of the profile image
  ///
  /// param: RegistrationPicViewModel [model]. BuildContext [context], double [width]
  /// returns: SafeArea
  /// Initial creation: 10/09/2020
  /// Last Updated: 10/09/2020
  void _showPicker(
      {@required BuildContext context,
      @required RegistrationPicViewModel model}) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                    leading: new Icon(KVKIcons.photo_camera_original),
                    title: new Text(model.lang().imagePicker[0]),
                    onTap: () {
                      model.imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                  new ListTile(
                      leading: new Icon(KVKIcons.gallery_original),
                      title: new Text(model.lang().imagePicker[1]),
                      onTap: () {
                        model.imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                ],
              ),
            ),
          );
        });
  }
}
