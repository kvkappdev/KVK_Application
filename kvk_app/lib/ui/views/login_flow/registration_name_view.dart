import 'package:flutter/material.dart';
import 'package:kvk_app/app/locator.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/app/router.gr.dart';
import 'package:kvk_app/ui/coloursheet.dart';
import 'package:kvk_app/ui/smart_widgets/screen_arguments.dart';
import 'package:kvk_app/ui/templates/kvk_background_painter.dart';
import 'package:kvk_app/ui/templates/kvk_box.dart';
import 'package:kvk_app/ui/viewmodels/login_flow/registration_name_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

final log = getLogger('Registration-Name-View');

class RegistrationNameView extends StatelessWidget {
  final _name = TextEditingController();
  final NavigationService _navigationService = locator<NavigationService>();

  /// Display the Verification view
  ///
  /// param: BuildContext[context]
  /// returns: Widget
  /// Initial creation: 8/09/2020
  /// Last Updated: 8/09/2020
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool keyboardIsOpened = MediaQuery.of(context).viewInsets.bottom != 0.0;
    final ScreenArguments screenArguments =
        ModalRoute.of(context).settings.arguments;

    return ViewModelBuilder<RegistrationNameViewModel>.reactive(
      builder: (context, model, child) => WillPopScope(
        onWillPop: (){
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
                painter: Box(0, 0.3),
                size: Size(screenWidth, screenHeight),
              ),
              registrationTitle(
                  width: screenWidth, height: screenHeight, model: model),
              registrationMsg(
                  width: screenWidth, height: screenHeight, model: model),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    input(
                        model: model, width: screenWidth, height: screenHeight),
                    error(width: screenWidth, model: model),
                    inputNotice(
                        width: screenWidth, height: screenHeight, model: model),
                  ],
                ),
              ),
              Container(
                margin: keyboardIsOpened
                    ? (EdgeInsets.only(
                        top: ((screenHeight -
                                    MediaQuery.of(context).viewInsets.bottom) *
                                0.95) -
                            20 -
                            (25 * (screenHeight / 683)),
                        left: screenWidth * 0.8))
                    : (EdgeInsets.only(
                        top: screenHeight * 0.9, left: screenWidth * 0.8)),
                child: FloatingActionButton(
                  backgroundColor: Colour.kvk_orange,
                  child: Icon(Icons.keyboard_arrow_right),
                  onPressed: () {
                    if (_name.text != "") {
                      model.setName(_name.text);
                      if (screenArguments != null) {
                        if (screenArguments.routeFrom ==
                            Routes.registrationFinaliseView) {
                          String routeDestination = screenArguments.routeFrom;
                          screenArguments.resetScreenArgument();
                          _navigationService.navigateTo(routeDestination);
                        } else {
                          _navigationService
                              .navigateTo(Routes.registrationPicView);
                        }
                      } else {
                        _navigationService
                            .navigateTo(Routes.registrationPicView);
                      }
                    } else {
                      model.setErrorVisible(true);
                      model.rebuild();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      viewModelBuilder: () => RegistrationNameViewModel(),
    );
  }

  /// Creates the title for the page
  /// param: double [width], double [height]
  /// returns: Container
  /// Initial creation: 08/09/2020
  /// Last Updated: 08/09/2020
  Widget registrationTitle(
      {@required RegistrationNameViewModel model,
      @required double width,
      @required double height}) {
    return Container(
      margin: new EdgeInsets.only(top: height * 0.2, left: width * 0.05),
      child: Text(
        model.lang().registrationNameTitle,
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
  /// Initial creation: 08/09/2020
  /// Last Updated: 08/09/2020
  Widget registrationMsg(
      {@required RegistrationNameViewModel model,
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

  /// Creates the TextField for the name, which can be editied, as well as deals with the suffix icon on error
  /// param: double [width], double [height]
  /// returns: Container
  /// Initial creation: 08/09/2020
  /// Last Updated: 08/09/2020
  Widget input(
      {@required RegistrationNameViewModel model,
      @required double width,
      @required double height}) {
    if (model.getName() != _name.text) {
      _name.text = model.getName();
    }
    return Container(
      margin: new EdgeInsets.only(
          top: height * 0.35, right: width * 0.05, left: width * 0.05),
      child: TextField(
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
        controller: _name,
        onChanged: (text) {
          model.setName(_name.text);
          model.setErrorVisible(false);
          model.rebuild();
        },
      ),
    );
  }

  /// Creates text about the name being displayed to other users
  /// param: double [width], double [height]
  /// returns: Container
  /// Initial creation: 08/09/2020
  /// Last Updated: 08/09/2020
  Widget inputNotice(
      {@required RegistrationNameViewModel model,
      @required double width,
      @required double height}) {
    return Container(
      margin: new EdgeInsets.only(left: width * 0.08),
      child: Text(
        model.lang().registrationNameInputNotice,
        style: TextStyle(
            color: Colour.kvk_black,
            fontFamily: "Lato",
            fontSize: 14,
            height: 1.4,
            fontWeight: FontWeight.w400),
      ),
    );
  }

  /// Creates the error text under the field
  /// param: double [width], double [height]
  /// returns: Container
  /// Initial creation: 08/09/2020
  /// Last Updated: 08/09/2020
  Widget error(
      {@required RegistrationNameViewModel model, @required double width}) {
    return Container(
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
