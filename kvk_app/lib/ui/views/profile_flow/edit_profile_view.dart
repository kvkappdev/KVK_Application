import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/router.gr.dart';
import 'package:kvk_app/icons/kvk_icons.dart';
import 'package:kvk_app/services/internal_profile_service.dart';
import 'package:kvk_app/ui/coloursheet.dart';
import 'package:kvk_app/ui/smart_widgets/delete_alert.dart';
import 'package:kvk_app/ui/smart_widgets/cancelCrossButtonResizable.dart';
import 'package:kvk_app/ui/smart_widgets/confirmTickButtonResizable.dart';
import 'package:kvk_app/ui/templates/kvk_plain_background.dart';
import 'package:kvk_app/ui/templates/kvk_box.dart';
import 'package:kvk_app/ui/viewmodels/profile_flow/edit_profile_viewmodel.dart';
import 'package:stacked/stacked.dart';

class EditProfileView extends StatelessWidget {
  final InternalProfileService _internalProfileService =
      locator<InternalProfileService>();
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return ViewModelBuilder<EditProfileViewModel>.reactive(
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
                      height: screenHeight * 0.125,
                      margin: new EdgeInsets.only(top: screenWidth * 0.05),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          crossButton(width: screenWidth, model: model),
                          Container(
                            margin:
                                new EdgeInsets.only(right: screenWidth * 0.4),
                            child: Text(
                              model.lang().editProfile,
                              style: TextStyle(
                                  color: Colour.kvk_white, fontSize: 20),
                            ),
                          ),
                          tickButton(
                              context: context,
                              width: screenWidth,
                              model: model),
                        ],
                      ),
                    ),
                    Container(
                      margin: new EdgeInsets.only(top: screenHeight * 0.175),
                      child: Column(children: <Widget>[
                        Align(
                          alignment: Alignment.center,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: <Widget>[
                              imageInput(
                                  model: model,
                                  context: context,
                                  width: screenWidth),
                              inputAction(
                                  model: model,
                                  context: context,
                                  width: screenWidth),
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: new EdgeInsets.only(
                              top: screenHeight * 0.05,
                              left: screenWidth * 0.05),
                          child: Text(
                            model.lang().name,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        textInput(
                            model: model,
                            width: screenWidth,
                            height: screenHeight),
                        error(width: screenWidth, model: model),
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: new EdgeInsets.only(
                              top: screenHeight * 0.05,
                              left: screenWidth * 0.05),
                          child: Text(
                            model.lang().phoneNumberText,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              alignment: Alignment.centerLeft,
                              margin: new EdgeInsets.only(
                                  top: screenHeight * 0.01,
                                  left: screenWidth * 0.075),
                              child: Text(
                                _internalProfileService.getMobile(),
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerRight,
                              margin: new EdgeInsets.only(
                                  top: screenHeight * 0.01,
                                  right: screenWidth * 0.075),
                              child: InkWell(
                                onTap: () {
                                  model.navigateToNewNumberRegistration();
                                },
                                child: Text(
                                  model.lang().changeNumber,
                                  style: TextStyle(
                                      fontSize: 14, color: Colour.kvk_orange),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ]),
                    ),
                    Container(
                      child: deleteProfile(
                        width: screenWidth,
                        height: screenHeight,
                        model: model,
                        onPress: () {
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (_) {
                                return DeleteDialog(
                                    deleteMessageDetails:
                                        model.lang().deleteDialogMessages);
                              });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        viewModelBuilder: () => EditProfileViewModel());
  }

  Widget deleteProfile(
      {@required double width,
      @required double height,
      @required Function onPress,
      @required EditProfileViewModel model}) {
    return Container(
      margin: new EdgeInsets.fromLTRB(20.0, height * 0.85, 20.0, 20.0),
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
      ),
      child: FlatButton(
        shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Colour.kvk_error_red,
              width: 1,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(50)),
        child: Text(
          model.lang().deleteProfile.toUpperCase(),
          style: TextStyle(
              fontSize: 18, fontFamily: "Lato", color: Colour.kvk_error_red),
        ),
        textColor: Colour.kvk_white,
        padding: EdgeInsets.all(16),
        onPressed: onPress,
        color: Colour.kvk_white,
      ),
    );
  }

  Widget imageInput(
      {@required EditProfileViewModel model,
      @required BuildContext context,
      @required double width}) {
    return Container(
      child: !model.checkDefaultPic()
          ? FlatButton(
              onPressed: () {
                _showPicker(context: context, model: model);
                model.rebuild();
              },
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                backgroundImage: model.getIsImageChanged()
                    ? FileImage(File(model.getPic()))
                    : _internalProfileService.getProfilePic().image,
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

  void _showPicker(
      {@required BuildContext context, @required EditProfileViewModel model}) {
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

  Widget crossButton(
      {@required double width, @required EditProfileViewModel model}) {
    return Container(
      // alignment: Alignment.,
      child: RCrossButton(
        size: width * 0.1,
        color: Colour.kvk_white,
        onPressed: () {
          model.back(routeName: Routes.profileView);
        },
      ),
    );
  }

  Widget tickButton({
    @required BuildContext context,
    @required double width,
    @required EditProfileViewModel model,
  }) {
    return Container(
      child: RTickButton(
          color: model.hasProfileChanged()
              ? Colour.kvk_white
              : Colour.kvk_white.withOpacity(0.5),
          onPressed: () {
            if (model.hasProfileChanged()) {
              if (!model.getIsNameChanged()) {
                model.setName(_internalProfileService.getName());
              }
              if (model.getName() != "") {
                if (!model.getIsImageChanged()) {
                  model.updateProfileName(context);
                } else {
                  model.updateProfile(context);
                }
              } else {
                model.setErrorVisible(true);
                print(model.getErrorVisible());
                model.rebuild();
              }
            }
          }),
    );
  }

  Widget inputAction(
      {@required EditProfileViewModel model,
      @required BuildContext context,
      @required double width}) {
    return Container(
      child: !model.checkDefaultPic()
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
    );
  }

  Widget textInput(
      {@required EditProfileViewModel model,
      @required double width,
      @required double height}) {
    return Container(
      margin: new EdgeInsets.only(right: width * 0.05, left: width * 0.05),
      child: TextFormField(
        initialValue: model.getName(),
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          suffixIcon: !model.getErrorVisible()
              ? null
              : Icon(
                  Icons.error,
                  color: Colour.kvk_error_red,
                ),
          hintStyle: TextStyle(color: Colour.kvk_grey),
          hintText: model.lang().registrationNameHint,
          enabledBorder: !model.getErrorVisible()
              ? UnderlineInputBorder(
                  borderSide: BorderSide(color: Colour.kvk_grey, width: 2))
              : OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Colour.kvk_error_red, width: 2)),
          filled: true,
          fillColor: Colour.kvk_white,
        ),
        onChanged: (text) {
          model.setName(text);
          model.setErrorVisible(false);
          model.rebuild();
        },
      ),
    );
  }

  Widget error({@required EditProfileViewModel model, @required double width}) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: new EdgeInsets.only(left: width * 0.08),
      child: Text(
        model.lang().registrationNameError,
        style: TextStyle(
            color: model.getErrorVisible()
                ? Colour.kvk_error_red
                : Colors.transparent,
            fontFamily: "Lato",
            fontSize: 11,
            height: 1.4,
            fontWeight: FontWeight.w400),
      ),
    );
  }
}
