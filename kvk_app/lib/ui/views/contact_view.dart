import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/icons/kvk_icons.dart';
import 'package:kvk_app/services/internal_profile_service.dart';
import 'package:kvk_app/ui/coloursheet.dart';
import 'package:kvk_app/ui/smart_widgets/backButtonResizable.dart';
import 'package:kvk_app/ui/smart_widgets/button.dart';
import 'package:kvk_app/ui/templates/kvk_plain_background.dart';
import 'package:kvk_app/ui/templates/kvk_box.dart';
import 'package:kvk_app/ui/viewmodels/contact_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactView extends StatelessWidget {
  final InternalProfileService _internalProfileService =
      locator<InternalProfileService>();
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return ViewModelBuilder<ContactViewModel>.reactive(
        builder: (context, model, child) => WillPopScope(
              onWillPop: () {
                return model.onBackPressed();
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
                      // margin: new EdgeInsets.only(top: screenWidth * 0.05),
                      child: Row(
                        children: <Widget>[
                          backButton(width: screenWidth, model: model),
                          Container(
                            margin:
                                new EdgeInsets.only(top: screenHeight * 0.025),
                            child: Text(
                              model.lang().kvk,
                              style: TextStyle(
                                  color: Colour.kvk_white, fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Stack(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.1),
                                  child: Container(
                                    margin: new EdgeInsets.only(
                                        top: screenHeight * 0.225),
                                    height: 1.0,
                                    width: screenWidth,
                                    color: Colour.kvk_grey,
                                  ),
                                ),
                                Container(
                                  child: Icon(
                                    KVKIcons.leaf_figma_exported_custom,
                                    size: 70,
                                    color: Colour.kvk_success_green,
                                  ),
                                  alignment: Alignment.topCenter,
                                  margin: new EdgeInsets.only(
                                      top: (screenHeight * 0.225) - 45),
                                ),
                              ],
                            ),
                            Container(
                              margin: new EdgeInsets.only(
                                  right: screenWidth * 0.1,
                                  left: screenWidth * 0.1,
                                  top: screenHeight * 0.025),
                              child: Text(
                                model.lang().contactText,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 16),
                              ),
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              margin: new EdgeInsets.only(
                                  left: screenWidth * 0.1,
                                  top: screenHeight * 0.025),
                              child: Text(
                                model.lang().mondayToFriday,
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              margin: new EdgeInsets.only(
                                  left: screenWidth * 0.1,
                                  top: screenHeight * 0.005),
                              child: Text(
                                "8am - 5pm",
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              margin: new EdgeInsets.only(
                                  left: screenWidth * 0.1,
                                  top: screenHeight * 0.04),
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.phone_in_talk, size: 35),
                                  Padding(
                                      padding: new EdgeInsets.only(left: 10),
                                      child: Text(
                                        "+917428730930",
                                      )),
                                ],
                              ),
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              margin: new EdgeInsets.only(
                                  left: screenWidth * 0.1,
                                  top: screenHeight * 0.01),
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.mail_outline, size: 35),
                                  Padding(
                                      padding: new EdgeInsets.only(left: 10),
                                      child: Text(
                                        "kvkdevteam@gmail.com",
                                      )),
                                ],
                              ),
                            ),
                            contactButton(
                              width: screenWidth,
                              height: screenHeight,
                              model: model,
                              onPress: () {
                                //WARNING: THIS IS AN ACTUAL NUMBER FOR KVK IN INDIA - CALL AT OWN RISK
                                launch("tel://+917428730930");
                              },
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
        viewModelBuilder: () => ContactViewModel());
  }

  Widget contactButton(
      {@required double width,
      @required double height,
      @required Function onPress,
      @required ContactViewModel model}) {
    return Container(
      margin: new EdgeInsets.fromLTRB(20.0, height * 0.025, 20.0, 20.0),
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
      ),
      child:
          Button(text: model.lang().directCall.toUpperCase(), onPress: onPress),
    );
  }
}

Widget backButton({@required double width, @required ContactViewModel model}) {
  return Container(
    margin: new EdgeInsets.only(top: width * 0.05, left: width * 0),
    child: RBackButton(
      size: width * 0.1,
      color: Colour.kvk_white,
      onPressed: () async {
        model.onBackPressed();
      },
    ),
  );
}
