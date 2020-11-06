import 'package:flutter/cupertino.dart';
import 'package:kvk_app/ui/coloursheet.dart';



class Box extends CustomPainter {
  double x, y, width, height;
  Color colour;
  bool requiresShadow;
  Box(double x, double y,
      {double width, double height, this.requiresShadow = false, this.colour = Colour.kvk_white}) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
  }

  /// Paints and draws a box on the screen, if no color is provided, the color will be white
  ///
  /// param: Canvas [canvas], Size [size]
  /// returns: 
  /// Initial creation: 22/09/2020
  /// Last Updated: 22/09/2020
  @override
  void paint(Canvas canvas, Size size) {
    final phoneWidth = size.width;
    final phoneHeight = size.height;
    double finalWidth, finalHeight;
    Paint paint = Paint();
    if (width != null) {
      if (width.compareTo(phoneWidth) == -1) {
        finalWidth = width;
      } else {
        finalWidth = phoneWidth;
      }
    } else {
      finalWidth = phoneWidth;
    }

    if (height != null) {
      if (height.compareTo(phoneHeight) == -1) {
        finalHeight = height;
      } else {
        finalHeight = phoneHeight;
      }
    } else {
      finalHeight = phoneHeight;
    }

    Path box = Path();
    box.addRect(Rect.fromLTRB(
        phoneWidth * x, phoneHeight * y, finalWidth, finalHeight));
    paint.color = colour;
    requiresShadow?canvas.drawShadow(box.shift(Offset(0, -5)), Colour.kvk_black, 2.0, true):null;
    canvas.drawPath(box, paint);


  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
