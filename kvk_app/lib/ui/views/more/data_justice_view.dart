import 'package:flutter/material.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/app/router.gr.dart';
import 'package:kvk_app/ui/coloursheet.dart';
import 'package:kvk_app/ui/smart_widgets/backButtonResizable.dart';
import 'package:kvk_app/ui/templates/kvk_background_painter.dart';
import 'package:kvk_app/ui/templates/kvk_box.dart';
import 'package:kvk_app/ui/viewmodels/more/data_justice_viewmodel.dart';
import 'package:stacked/stacked.dart';

final log = getLogger("data_justice");

class DataJusticeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return ViewModelBuilder<DataJusticeViewModel>.reactive(
      builder: (context, model, child) => WillPopScope(
        onWillPop: () {
          return model.onBackPressed();
        },
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              CustomPaint(
                painter: BackgroundPainter(),
                size: Size(screenWidth, screenHeight),
              ),
              CustomPaint(
                painter: Box(0, 0.25, requiresShadow: true),
                size: Size(screenWidth, screenHeight),
              ),
              backButton(width: screenWidth, model: model),
              dataJusticeTitle(
                  width: screenWidth, height: screenHeight, model: model),
              logo(screenWidth: screenWidth, screenHeight: screenHeight),
              Container(
                margin: new EdgeInsets.only(top: screenHeight * 0.25),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                    margin: new EdgeInsets.only(
                        left: screenWidth * 0.05, right: screenWidth * 0.05),
                    child: dataJusticeText(model: model),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      viewModelBuilder: () => DataJusticeViewModel(),
    );
  }

  /// Creates the title for the page
  /// param: double [width], double [height]
  /// returns: Container
  /// Initial creation: 05/10/2020
  /// Last Updated: 05/10/2020
  Widget dataJusticeTitle(
      {@required DataJusticeViewModel model,
      @required double width,
      @required double height}) {
    return Container(
      margin: new EdgeInsets.only(top: height * 0.2, left: width * 0.05),
      child: Text(
        model.lang().dataJusticeTitle,
        style: TextStyle(
            color: Colour.kvk_white,
            fontFamily: "Lato",
            fontSize: 24,
            height: 1.2,
            fontWeight: FontWeight.w700),
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
      {@required double width, @required DataJusticeViewModel model}) {
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

  Widget dataJusticeText({@required DataJusticeViewModel model}) {
    return Text(
      model.lang().dataJustice,
      textAlign: TextAlign.justify,
    );
  }
}
