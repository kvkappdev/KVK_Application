import 'package:flutter/cupertino.dart';
import 'package:kvk_app/ui/coloursheet.dart';

class PlainBackground extends CustomPainter {

  /// Handles the solid green background
  ///
  /// param: Canvas [canvas], Size [size]
  /// returns: 
  /// Initial creation: 22/09/2020
  /// Last Updated: 22/09/2020
  @override
  void paint(Canvas canvas, Size size) {
    final phoneHeight = size.height;
    final phoneWidth = size.width;
    Paint paint = Paint();

    Path mainBackground = Path();
    mainBackground.addRect(Rect.fromLTRB(0, 0, phoneWidth, phoneHeight));
    paint.color = Colour.kvk_background_green;
    canvas.drawPath(mainBackground, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
