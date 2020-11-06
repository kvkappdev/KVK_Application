import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kvk_app/ui/coloursheet.dart';

class Button extends StatelessWidget {
  final Function onPress;
  final String text;
  final bool keyboardActive;
  final Color colour;
  final Color fontColour;
  final double width;

  Button(
      {@required this.text,
      @required this.onPress,
      this.keyboardActive = false,
      this.colour = Colour.kvk_orange,
      this.width = double.infinity,
      this.fontColour = Colour.kvk_white});

  /// Create a button with variables such as color and, text and onPress method
  /// param: BuildContext [context]
  /// returns: Container
  /// Initial creation: 5/09/2020
  /// Last Updated: 5/09/2020
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: new EdgeInsets.all(20.0),
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: keyboardActive ? Colour.kvk_white : Colour.kvk_grey,
            spreadRadius: 0,
            blurRadius: keyboardActive ? 0 : 1,
            offset: keyboardActive ? Offset(0, 0) : Offset(0, 5),
          ),
        ],
        shape: BoxShape.rectangle,
      ),
      child: FlatButton(
        shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Colour.kvk_white,
              width: 4,
              style: keyboardActive ? BorderStyle.solid : BorderStyle.none,
            ),
            borderRadius: BorderRadius.circular(50)),
        child: Text(
          text,
          style: TextStyle(
              fontSize: 18, fontFamily: "Lato", fontWeight: FontWeight.w700),
        ),
        textColor: fontColour,
        padding: EdgeInsets.all(16),
        onPressed: onPress,
        color: colour,
      ),
    );
  }
}
