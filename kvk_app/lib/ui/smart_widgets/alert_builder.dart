import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:kvk_app/ui/coloursheet.dart';

final log = getLogger("Alert-Builder");

class AlertBuilder {
  Alert alert;
  bool _errorState = false;

  final String title;
  final Color titleColour;
  final String message;
  final Color msgColour;
  final IconData icon;
  final Color iconColour;
  final Function onPress;
  final BuildContext context;
  final bool loadingAlert;
  final Color buttonColour;
  final bool isOverlayTapDismiss;
  final bool hasCloseButton;
  final String buttonText;

  AlertBuilder(
      {@required this.title,
      @required this.context,
      this.onPress,
      this.icon = Icons.explicit,
      this.message = "",
      this.loadingAlert = false,
      this.titleColour = Colour.kvk_black,
      this.msgColour = Colour.kvk_black,
      this.iconColour = Colour.kvk_black,
      this.buttonColour = Colour.kvk_orange,
      this.isOverlayTapDismiss = false,
      this.hasCloseButton = false,
      this.buttonText = ""});

  /// Creates an alert with details passed in from the user (e.g. icon, title and image)
  /// or creates a loading alert
  ///
  /// param:
  /// returns: Alert [alert]
  /// Initial creation: 08/09/2020
  /// Last Updated: 30/09/2020
  Alert createAlert() {
    alert = loadingAlert
        ? Alert(
            onWillPopActive: true,
            image: Image(
              image: new AssetImage("assets/gifs/kvk_loading_one.gif"),
              width: MediaQuery.of(context).size.width * 0.4,
              height: MediaQuery.of(context).size.width * 0.4,
              alignment: Alignment.center,
            ),
            style: AlertStyle(
              overlayColor: Colors.black87,
              isOverlayTapDismiss: false,
              isButtonVisible: false,
              titleStyle: TextStyle(
                  color: titleColour,
                  fontSize: 20,
                  fontFamily: "Lato",
                  fontWeight: FontWeight.w700),
              isCloseButton: false,
            ),
            title: title.toUpperCase(),
            context: context,
          )
        : Alert(
            onWillPopActive: true,
            image: Icon(
              icon,
              color: iconColour,
              size: MediaQuery.of(context).size.width * 0.4,
            ),
            title: title,
            context: context,
            desc: message,
            style: AlertStyle(
              overlayColor: Colors.black87,
              isOverlayTapDismiss: isOverlayTapDismiss,
              descStyle:
                  TextStyle(fontFamily: "Lato", color: msgColour, fontSize: 14),
              titleStyle: TextStyle(
                  color: titleColour,
                  fontSize: 20,
                  fontFamily: "Lato",
                  fontWeight: FontWeight.w700),
              isCloseButton: hasCloseButton,
            ),
            buttons: <DialogButton>[
                DialogButton(
                  radius: BorderRadius.circular(50),
                  width: MediaQuery.of(context).size.width * 0.35,
                  color: buttonColour,
                  onPressed: onPress,
                  child: Text(
                    buttonText,
                    style: TextStyle(
                        color: Colour.kvk_white,
                        fontSize: 18,
                        fontFamily: "Lato",
                        fontWeight: FontWeight.w700),
                  ),
                )
              ]);
    return alert;
  }

  /// Allows the dialog to be shown or dismissed as required
  /// param:
  /// returns:
  /// Initial creation: 08/09/2020
  /// Last Updated: 08/09/2020
  void showDialog() {
    alert.show();
  }

  void dismissDialog() {
    alert.dismiss();
  }

  /// Getters and setters to allow the dialog to set error state
  /// param: Varies
  /// returns: Varies
  /// Initial creation: 08/09/2020
  /// Last Updated: 08/09/2020
  void setErrorState(bool errorState) {
    _errorState = errorState;
  }

  bool getErrorState() {
    return _errorState;
  }
}
