import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/app/router.gr.dart';
import 'package:kvk_app/data_struct/internalUser.dart';
import 'package:kvk_app/ui/coloursheet.dart';
import 'package:kvk_app/ui/smart_widgets/backButtonResizable.dart';
import 'package:kvk_app/ui/smart_widgets/button.dart';
import 'package:kvk_app/ui/smart_widgets/dropDownButton.dart';
import 'package:kvk_app/ui/templates/kvk_background_painter.dart';
import 'package:kvk_app/ui/templates/kvk_box.dart';
import 'package:kvk_app/ui/viewmodels/more/administrator_viewmodel.dart';
import 'package:stacked/stacked.dart';

final log = getLogger("administratorView");

class AdministratorView extends StatelessWidget {
  final _mobileController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return ViewModelBuilder<AdministratorViewModel>.reactive(
      builder: (context, model, child) => WillPopScope(
        onWillPop: () {
          return model.onBackPressed();
        },
        child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: <Widget>[
            CustomPaint(
              painter: BackgroundPainter(),
              size: Size(screenWidth, screenHeight),
            ),
            CustomPaint(
              painter: Box(0, 0.25, colour: Colour.kvk_background_grey),
              size: Size(screenWidth, screenHeight),
            ),
            backButton(width: screenWidth, model: model),
            administratorTitle(
                width: screenWidth, height: screenHeight, model: model),
            logo(screenWidth: screenWidth, screenHeight: screenHeight),
            Container(
                margin: new EdgeInsets.only(top: screenHeight * 0.25),
                child: Column(children: <Widget>[
                  Container(
                    color: Colour.kvk_white,
                    child: Column(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.topLeft,
                          padding: new EdgeInsets.only(left: 20, top: 20),
                          child: Text(
                            "Search for user.",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        dropDownCallingCode(model: model, context: context),
                        mobileTextBox(model: model, context: context),
                        error(
                            model: model,
                            width: screenWidth,
                            height: screenHeight),
                        Container(
                          child: Button(
                            text: "SEARCH",
                            onPress: () async {
                              model.setErrorVisible(
                                  !model.validate(_mobileController.text));
                              log.d("Error: " +
                                  model.getErrorVisible().toString());
                              if (!model.getErrorVisible()) {
                                await model.getUserByPhoneNumber(
                                    mobile: model.getCallingCode() +
                                        model.clean(_mobileController.text),
                                    context: context);

                                if (model.getUser().databaseID != "-1") {
                                  model.setProfileFound(true);
                                  model.setRoleId(model.getUser().role);
                                  model.rebuild();
                                } else {
                                  model.setProfileFound(false);
                                  model.rebuild();
                                }
                              } else {
                                log.e("Invalid Number: " +
                                    _mobileController.text);
                                model.rebuild();
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  model.getProfileFound()
                      ? Card(
                          margin: new EdgeInsets.only(top: 5),
                          child: Container(
                              width: screenWidth,
                              padding: new EdgeInsets.all(10),
                              child: accountCard(
                                  context: context,
                                  model: model,
                                  user: model.getUser(),
                                  width: screenWidth)),
                        )
                      : Expanded(
                          child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                "No Results",
                                style: TextStyle(
                                    fontSize: 18, color: Colour.kvk_dark_grey),
                              )))
                ])),
          ],
        ),
      ),),
      viewModelBuilder: () => AdministratorViewModel(),
    );
  }

  Widget accountCard({
    @required AdministratorViewModel model,
    @required BuildContext context,
    @required double width,
    @required InternalUser user,
  }) {
    return Container(
      padding: new EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              accountDetails(
                  model: model, width: width, context: context, user: user),
              Container(
                margin: new EdgeInsets.only(top: 15),
                width: width * 0.85,
                alignment: Alignment.topRight,
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: Text(
                    "SAVE CHANGES",
                    style: TextStyle(color: Colour.kvk_white),
                  ),
                  color: model.getRoleId() != model.getUser().role
                      ? Colour.kvk_orange
                      : Colour.kvk_grey,
                  onPressed: () async {
                    if (model.getRoleId() != model.getUser().role) {
                      await model
                          .updateRole(
                              context: context,
                              role: model.getRoleId(),
                              userId: model.getUser().databaseID)
                          .whenComplete(() {
                        _mobileController.text = "";
                        model.rebuild();
                      });
                    }
                  },
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget accountDetails(
      {@required double width,
      @required AdministratorViewModel model,
      @required InternalUser user,
      @required BuildContext context}) {
    return Row(
      children: <Widget>[
        Container(
          decoration: new BoxDecoration(
            border: Border.all(
              color: Colour.kvk_nav_grey,
            ),
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Colors.transparent,
                backgroundImage: user.profilePic != "default"
                    ? NetworkImage(
                        user.profilePic,
                      )
                    : AssetImage("assets/img/blank_profile.png"),
                radius: width * 0.075,
              ),
            ],
          ),
        ),
        Container(
          padding: new EdgeInsets.only(left: 5),
          width: width * 0.85 -
              42, //8 padding +10 margin +8 container +8 contaienr?
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    user.name,
                    style: TextStyle(
                        color: Colour.kvk_post_grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Lato"),
                  ),
                  Text(
                    user.mobile,
                    style: TextStyle(
                        color: Colour.kvk_black,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Lato"),
                  ),
                ],
              ),
              dropDownButton(model)
              // moreButton(context: context, model: model, post: args.post),
            ],
          ),
        ),
      ],
    );
  }

  Widget dropDownButton(AdministratorViewModel model) {
    return Container(
        width: 115,
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            isExpanded: true,
            value: model.getRoleId(),
            onChanged: (int value) {
              model.setRoleId(value);
              model.changeRole();
            },
            iconEnabledColor: Colour.kvk_orange,
            style: TextStyle(color: Colour.kvk_black),
            selectedItemBuilder: (BuildContext context) {
              return model.getOptions().map((String value) {
                return Container(
                    alignment: Alignment.topRight,
                    child: Text(
                      model.getOptions()[model.getRoleId()],
                      style: TextStyle(color: Colour.kvk_orange, height: 2.5),
                      textAlign: TextAlign.center,
                    ));
              }).toList();
            },
            items:
                model.getOptions().map<DropdownMenuItem<int>>((String value) {
              return DropdownMenuItem<int>(
                value: model.getOptions().indexOf(value),
                child: Text(value),
              );
            }).toList(),
          ),
        ));
  }

  /// Creates the text field for entering a number, and ensures only numbers are entered into the boc
  ///
  /// param: VerificationViewModel [model], BuildContext [context]
  /// returns: Container
  /// Initial creation: 8/09/2020
  /// Last Updated: 8/09/2020
  Widget mobileTextBox(
      {@required AdministratorViewModel model,
      @required BuildContext context}) {
    return Container(
        padding: new EdgeInsets.only(top: 10),
        child: SizedBox(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
              Container(
                margin: new EdgeInsets.only(left: 10.0),
                child: Text(
                  model.getCallingCode(),
                  style: TextStyle(fontSize: 18, color: Colour.kvk_black),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.6,
                alignment: Alignment.centerRight,
                margin: new EdgeInsets.only(left: 15.0),
                child: TextFormField(
                  inputFormatters: [
                    new WhitelistingTextInputFormatter(RegExp("[0-9]")),
                  ],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    suffixIcon: !model.getErrorVisible()
                        ? null
                        : Icon(
                            Icons.error,
                            color: Colour.kvk_error_red,
                          ),
                    hintStyle: TextStyle(color: Colour.kvk_nav_grey),
                    hintText: model.lang().enter,
                    enabledBorder: !model.getErrorVisible()
                        ? OutlineInputBorder(
                            borderSide: BorderSide(color: Colour.kvk_grey))
                        : OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colour.kvk_error_red, width: 2)),
                    filled: true,
                    fillColor: Colour.kvk_white,
                  ),
                  controller: _mobileController,
                  onChanged: (_) {
                    model.setErrorVisible(false);
                    model.rebuild();
                  },
                  onFieldSubmitted: (String str) {
                    if (_mobileController.text != "") {
                      // model.authenticate(
                      //     model.getCallingCode() + _mobileController.text,
                      //     context);
                    }
                  },
                ),
              )
            ])));
  }

  /// Creates the calling (country) code drop down menu
  ///
  /// param: VerificationViewModel [model], BuildContext [context]
  /// returns: Container
  /// Initial creation: 8/09/2020
  /// Last Updated: 8/09/2020
  Widget dropDownCallingCode(
      {@required AdministratorViewModel model,
      @required BuildContext context}) {
    return Container(
        margin: new EdgeInsets.only(top: 10),
        width: MediaQuery.of(context).size.width * 0.75,
        child: CustomDropdownButton(
          value: model.getDropDownValue(),
          iconSize: 30,
          elevation: 16,
          style: TextStyle(
              color: Colour.kvk_black,
              fontSize: 18,
              fontFamily: "Lato",
              height: 1.22),
          onChanged: (value) {
            model.setDropDownValue(value);
            model.setCallingCode(value);
            model.rebuild();
          },
          items: [
            DropdownMenuItem(
              child: Text(model.lang().countries[0]),
              value: 0,
            ),
            DropdownMenuItem(
              child: Text(model.lang().countries[1]),
              value: 1,
            ),
          ],
        ));
  }

  /// Creates the title for the page
  /// param: double [width], double [height]
  /// returns: Container
  /// Initial creation: 05/10/2020
  /// Last Updated: 05/10/2020
  Widget administratorTitle(
      {@required AdministratorViewModel model,
      @required double width,
      @required double height}) {
    return Container(
      margin: new EdgeInsets.only(top: height * 0.2, left: width * 0.05),
      child: Text(
        "Administrator",
        style: TextStyle(
            color: Colour.kvk_white,
            fontFamily: "Lato",
            fontSize: 24,
            height: 1.2,
            fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget error({
    @required double width,
    @required double height,
    @required AdministratorViewModel model,
  }) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: new EdgeInsets.only(left: width * 0.30),
      child: Text(
        model.lang().verificationError,
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

  /// Creates the back button at the top left of the page
  ///
  /// param: double [width], DataJusticeViewModel [model]
  /// returns: Container
  /// Initial creation: 05/10/2020
  /// Last Updated: 05/10/2020
  Widget backButton(
      {@required double width, @required AdministratorViewModel model}) {
    return Container(
      margin: new EdgeInsets.only(top: width * 0.05, left: width * 0),
      child: RBackButton(
        size: width * 0.1,
        color: Colour.kvk_white,
        onPressed: () {
          model.back(routeName: Routes.moreView);
        },
      ),
    );
  }

  /// Creates the logos on the right of the page
  ///
  /// param: double [screenWidth], double [screenHeight]
  /// returns: Row
  /// Initial creation: 05/10/2020
  /// Last Updated: 05/10/2020
  Widget logo({@required double screenWidth, @required double screenHeight}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          padding: new EdgeInsets.only(
            right: screenWidth * 0.01,
            top: screenHeight * 0.17,
          ),
          child: Image(
            image: new AssetImage("assets/img/svm_logo.png"),
            height: screenHeight * 0.07,
          ),
        ),
        Container(
          padding: new EdgeInsets.only(
            left: screenWidth * 0.01,
            right: screenWidth * 0.02,
            top: screenHeight * 0.17,
          ),
          child: Image(
            image: new AssetImage("assets/img/icar_logo.png"),
            height: screenHeight * 0.07,
          ),
        ),
      ],
    );
  }

  Widget dataJusticeText({@required AdministratorViewModel model}) {
    return Text(
      model.lang().dataJustice,
      textAlign: TextAlign.justify,
    );
  }
}
