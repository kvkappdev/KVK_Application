import 'package:flutter/material.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/app/router.gr.dart';
import 'package:kvk_app/services/authentication_service.dart';
import 'package:kvk_app/ui/coloursheet.dart';
import 'package:kvk_app/ui/smart_widgets/backButtonResizable.dart';
import 'package:kvk_app/ui/smart_widgets/button.dart';
import 'package:kvk_app/ui/templates/kvk_background_painter.dart';
import 'package:kvk_app/ui/templates/kvk_box.dart';
import 'package:kvk_app/ui/smart_widgets/pin_text_field.dart';
import 'package:kvk_app/ui/viewmodels/profile_flow/change_number_code_viewmodel.dart';
import 'package:stacked/stacked.dart';

final log = getLogger('Change-Number-Code-View');

class ChangeNumberCodeView extends StatelessWidget {
  final AuthenticationService authenticationService =
      locator<AuthenticationService>();

  /// Display the Verification Code view
  ///
  /// param: BuildContext[context]
  /// returns: ViewModelBuilder
  /// Initial creation: 8/09/2020
  /// Last Updated: 8/09/2020
  @override
  Widget build(BuildContext context) {
    bool keyboardIsOpened = MediaQuery.of(context).viewInsets.bottom != 0.0;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return ViewModelBuilder<ChangeNumberCodeViewmodel>.reactive(
      builder: (context, model, child) => Scaffold(
        body: Stack(
          children: <Widget>[
            CustomPaint(
              painter: BackgroundPainter(),
              size: Size(width, height),
            ),
            CustomPaint(
              painter: Box(0, 0.8),
              size: Size(width, height),
            ),
            backButton(width: width, model: model),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                verificationTitle(model),
                verificationMsg(model),
                codeInput(model: model, context: context),
              ],
            ),
            Container(
                margin: keyboardIsOpened
                    ? (EdgeInsets.only(
                        top: ((MediaQuery.of(context).size.height -
                                    MediaQuery.of(context).viewInsets.bottom) *
                                0.8) -
                            20 -
                            (25 * (MediaQuery.of(context).size.height / 683))))
                    : (EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.8)),
                child: Column(children: <Widget>[
                  model.validCode()
                      ? Button(
                          text: model.lang().login.toUpperCase(),
                          onPress: () {
                            log.d("Login with code: " + model.getCode());
                            model.signIn(context);
                          },
                          keyboardActive: keyboardIsOpened,
                        )
                      : Button(
                          text: model.lang().login.toUpperCase(),
                          onPress: () {
                            log.d("Button inactive");
                          },
                          keyboardActive: keyboardIsOpened,
                          colour: Colour.kvk_grey,
                        ),
                  resendCode(model: model, keyboardIsOpened: keyboardIsOpened),
                ])),
          ],
        ),
      ),
      viewModelBuilder: () => ChangeNumberCodeViewmodel(),
    );
  }

  /// Creates text for the resend code text button
  ///
  /// param: VerificationCodeViewModel [model], bool [keyboardIsOpen]
  /// returns: Container
  /// Initial creation: 8/09/2020
  /// Last Updated: 8/09/2020
  Widget resendCode(
      {@required ChangeNumberCodeViewmodel model,
      bool keyboardIsOpened = false}) {
    return !keyboardIsOpened
        ? Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  model.lang().verificationCodeResend[0],
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.2,
                    fontFamily: "Lato",
                    color: Colour.kvk_dark_grey,
                  ),
                ),
                InkWell(
                  onTap: () => model.resendCode(),
                  child: Text(
                    model.lang().verificationCodeResend[1],
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 14,
                      height: 1.2,
                      fontFamily: "Lato",
                      color: Colour.kvk_orange,
                    ),
                  ),
                ),
              ],
            ),
          )
        : Container();
  }

  /// Creates a back button in the top left of the screen
  ///
  /// param: VerificationCodeViewModel [model], double [width]
  /// returns: Container
  /// Initial creation: 8/09/2020
  /// Last Updated: 8/09/2020
  Widget backButton(
      {@required double width, @required ChangeNumberCodeViewmodel model}) {
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

  /// Creates the title for the page
  ///
  /// param: VerificationCodeViewModel [model]
  /// returns: Column
  /// Initial creation: 8/09/2020
  /// Last Updated: 8/09/2020
  Widget verificationTitle(ChangeNumberCodeViewmodel model) {
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

  /// Creates the message for the page
  ///
  /// param: VerificationCodeViewModel [model]
  /// returns: Column
  /// Initial creation: 8/09/2020
  /// Last Updated: 8/09/2020
  Widget verificationMsg(ChangeNumberCodeViewmodel model) {
    return Column(children: <Widget>[
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            model.lang().verificationCodeMsg[0],
            style: TextStyle(
                color: Colour.kvk_white,
                fontFamily: "Lato",
                fontSize: 14,
                fontWeight: FontWeight.w400),
          ),
          Text(
            model.lang().verificationCodeMsg[1],
            style: TextStyle(
                color: Colour.kvk_white,
                fontFamily: "Lato",
                fontSize: 14,
                fontWeight: FontWeight.w700),
          ),
          Text(
            model.lang().verificationCodeMsg[2],
            style: TextStyle(
                color: Colour.kvk_white,
                fontFamily: "Lato",
                fontSize: 14,
                fontWeight: FontWeight.w400),
          ),
          SizedBox(
            height: 14.5,
          ),
        ],
      ),
      Text(
        authenticationService.mobile != null
            ? model.lang().verificationCodeMsg[3] + authenticationService.mobile
            : model.lang().verificationCodeMsg[4],
        style: TextStyle(
            color: Colour.kvk_white,
            fontFamily: "Lato",
            fontSize: 14,
            fontWeight: FontWeight.w400),
      )
    ]);
  }

  /// Create the 6 digit code input and sets the pin on change of these values
  ///
  /// param: VerificationCodeViewModel [model], BuildContext [context]
  /// returns: PinTextField
  /// Initial creation: 8/09/2020
  /// Last Updated: 8/09/2020
  Widget codeInput(
      {@required ChangeNumberCodeViewmodel model,
      @required BuildContext context}) {
    return PinTextField(
      fields: 6,
      textColor: Colour.kvk_white,
      fieldWidth: MediaQuery.of(context).size.width * 0.1,
      onChange: (String pin) {
        model.setCode(pin);
        model.rebuild();
      },
      onSubmit: (String pin) {
        if (model.validCode()) {
          model.signIn(context);
        }
      },
    );
  }
}
