import 'package:flutter/cupertino.dart';

class Logos extends StatelessWidget {

  /// Shows the logos on the top of the navigation bar
  ///
  /// param: BuildContext [context]
  /// returns: Row
  /// Initial creation: 29/09/2020
  /// Last Updated: 29/09/2020
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          padding: new EdgeInsets.only(
            right: screenWidth * 0.01,
            top: screenHeight * 0.04,
          ),
          child: Image(
            image: new AssetImage("assets/img/svm_logo.png"),
            height: screenHeight * 0.07,
          ),
        ),
        Container(
          padding: new EdgeInsets.only(
            left: screenWidth * 0.01,
            top: screenHeight * 0.04,
          ),
          child: Image(
            image: new AssetImage("assets/img/icar_logo.png"),
            height: screenHeight * 0.07,
          ),
        ),
      ],
    );
  }
}
