import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/app/router.gr.dart';
import 'package:kvk_app/ui/coloursheet.dart';
import 'package:kvk_app/ui/smart_widgets/backButtonResizable.dart';
import 'package:kvk_app/ui/smart_widgets/button.dart';
import 'package:kvk_app/ui/smart_widgets/dropDownButton.dart';
import 'package:kvk_app/ui/templates/kvk_background_painter.dart';
import 'package:kvk_app/ui/viewmodels/profile_flow/change_number_viewmodel.dart';
import 'package:stacked/stacked.dart';

final log = getLogger('Verification-View');

class ChangeNumberView extends StatelessWidget {
  final _mobileController = TextEditingController();

  /// Display the Verification view
  ///
  /// param: BuildContext[context]
  /// returns: Widget
  /// Initial creation: 8/09/2020
  /// Last Updated: 8/09/2020
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return ViewModelBuilder<ChangeNumberViewModel>.reactive(
      builder: (context, model, child) => Scaffold(
          body: CustomPaint(
              painter: BackgroundPainter(),
              child: Stack(
                children: <Widget>[
                  backButton(width: width, model: model),
                  Container(
                    padding: EdgeInsets.only(left: 32, right: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        verificationTitle(model),
                        verificationMsg(model),
                        interactBox(
                            model: model,
                            context: context,
                            width: width,
                            height: height),
                      ],
                    ),
                  ),
                ],
              ))),
      viewModelBuilder: () => ChangeNumberViewModel(),
    );
  }

  /// Display an error if the phone number is invalid
  ///
  /// param: bool [visible], doouble [width], double [height]
  /// returns: Container
  /// Initial creation: 8/09/2020
  /// Last Updated: 8/09/2020
  Widget error({
    @required double width,
    @required double height,
    @required ChangeNumberViewModel model,
  }) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: new EdgeInsets.only(left: width * 0.17),
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
  /// param: double [width], VerificationViewModel [model]
  /// returns: Container
  /// Initial creation: 8/09/2020
  /// Last Updated: 8/09/2020
  Widget backButton(
      {@required double width, @required ChangeNumberViewModel model}) {
    return Container(
      margin: new EdgeInsets.only(top: width * 0.05, left: width * 0),
      child: RBackButton(
        size: width * 0.1,
        color: Colour.kvk_white,
        onPressed: () {
          model.popBack();
        },
      ),
    );
  }

  /// Creates the Title for the page
  ///
  /// param: VerificationViewModel [model]
  /// returns: Column
  /// Initial creation: 8/09/2020
  /// Last Updated: 8/09/2020
  Widget verificationTitle(ChangeNumberViewModel model) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            model.lang().newNumberVerificationTitle,
            style: TextStyle(
                color: Colour.kvk_white,
                fontFamily: "Lato",
                fontSize: 24,
                fontWeight: FontWeight.w700),
          ),
          SizedBox(
            height: 22,
          ),
        ]);
  }

  /// Creates the white box which shows the country code, input for phone number
  /// and next button
  ///
  /// param: VerificationViewModel [model], BuildContext [context], double [width], double [height]
  /// returns: Container
  /// Initial creation: 8/09/2020
  /// Last Updated: 8/09/2020
  Widget interactBox(
      {@required ChangeNumberViewModel model,
      @required BuildContext context,
      @required double width,
      @required double height}) {
    return Container(
      margin: new EdgeInsets.symmetric(vertical: 25.0),
      decoration: new BoxDecoration(
          color: Colour.kvk_white,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Column(
        children: <Widget>[
          dropDownCallingCode(model: model, context: context),
          mobileTextBox(model: model, context: context),
          error(model: model, width: width, height: height),
          Container(
            child: Button(
              text: model.lang().next,
              onPress: () {
                model.setErrorVisible(!model.validate(_mobileController.text));
                log.d("Error: " + model.getErrorVisible().toString());
                if (!model.getErrorVisible()) {
                  model.authenticate(
                      model.getCallingCode() +
                          model.clean(_mobileController.text),
                      context);
                } else {
                  log.e("Invalid Number: " + _mobileController.text);
                  model.rebuild();
                }
              },
            ),
          )
        ],
      ),
    );
  }

  /// Creates the calling (country) code drop down menu
  ///
  /// param: VerificationViewModel [model], BuildContext [context]
  /// returns: Container
  /// Initial creation: 8/09/2020
  /// Last Updated: 8/09/2020
  Widget dropDownCallingCode(
      {@required ChangeNumberViewModel model, @required BuildContext context}) {
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

  /// Creates the text field for entering a number, and ensures only numbers are entered into the boc
  ///
  /// param: VerificationViewModel [model], BuildContext [context]
  /// returns: Container
  /// Initial creation: 8/09/2020
  /// Last Updated: 8/09/2020
  Widget mobileTextBox(
      {@required ChangeNumberViewModel model, @required BuildContext context}) {
    return Container(
        padding: new EdgeInsets.only(top: 10),
        child: SizedBox(
            child: Row(
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
                      model.authenticate(
                          model.getCallingCode() + _mobileController.text,
                          context);
                    }
                  },
                ),
              )
            ])));
  }

  /// Creates the text for message under the title. This is split to allow for bolding of text.
  ///
  /// param: VerificationViewModel [model]
  /// returns: Column
  /// Initial creation: 8/09/2020
  /// Last Updated: 8/09/2020
  Widget verificationMsg(ChangeNumberViewModel model) {
    return Column(children: <Widget>[
      Text(
        model.lang().verificationMsg[0],
        style: TextStyle(
            color: Colour.kvk_white,
            fontFamily: "Lato",
            fontSize: 14,
            fontWeight: FontWeight.w400),
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            model.lang().verificationMsg[1],
            style: TextStyle(
                color: Colour.kvk_white,
                fontFamily: "Lato",
                fontSize: 14,
                fontWeight: FontWeight.w700),
          ),
          Text(
            model.lang().verificationMsg[2],
            style: TextStyle(
                color: Colour.kvk_white,
                fontFamily: "Lato",
                fontSize: 14,
                fontWeight: FontWeight.w400),
          ),
        ],
      )
    ]);
  }
}
