import 'package:flutter/cupertino.dart';
import 'package:kvk_app/ui/coloursheet.dart';

class BackgroundPainter extends CustomPainter {

  /// Creates and draws the ovals at the top of the screen when required, as well as a solid green background
  ///
  /// param: Canvas [canvas], Size [size]
  /// returns: 
  /// Initial creation: 22/09/2020
  /// Last Updated: 22/09/2020
  @override
  void paint(Canvas canvas, Size size) {
    final phoneHeight = size.height;
    final phoneWidth = size.width;
    final double staticHeight = 800;
    Paint paint = Paint();

    Path mainBackground = Path();
    mainBackground.addRect(Rect.fromLTRB(0, 0, phoneWidth, phoneHeight));
    paint.color = Colour.kvk_background_green;
    canvas.drawPath(mainBackground, paint);

    Path backOvalPath = Path();
    backOvalPath.moveTo(phoneWidth * 0.22, 0);
    backOvalPath.quadraticBezierTo(phoneWidth * 0.25, staticHeight * 0.13,
        phoneWidth * 0.5, staticHeight * 0.13);
    backOvalPath.quadraticBezierTo(phoneWidth * 0.7, staticHeight * 0.13,
        phoneWidth * 0.90, staticHeight * 0);

    backOvalPath.close();

    paint.color = Colour.kvk_eclipse_1;
    canvas.drawPath(backOvalPath, paint);

    Path frontOvalPath = Path();
    frontOvalPath.moveTo(phoneWidth * 0.45, 0);
    frontOvalPath.quadraticBezierTo(phoneWidth * 0.65, staticHeight * 0.17,
        phoneWidth, staticHeight * 0.17);
    frontOvalPath.lineTo(phoneWidth, 0);

    frontOvalPath.close();

    paint.color = Colour.kvk_eclipse_2;
    canvas.drawPath(frontOvalPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
