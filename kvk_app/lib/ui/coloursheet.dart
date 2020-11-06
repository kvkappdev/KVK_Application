import 'package:flutter/cupertino.dart';

/// Colour sheet - holds all the colors used throughout the application after flutter initialises.
/// This includes colors that are also in the base library, as this allows for them to be easily changed if
/// that is required.
///
/// Initial creation: 22/09/2020
/// Last Updated: 22/09/2020
class Colour {
  //Note: kvk_background_green also needs to be changed in the android color sheet if a change of color occurs (for the splash screen)
  static const Color kvk_background_green = Color.fromRGBO(50, 161, 34, 1);
  static const Color kvk_white = Color.fromRGBO(255, 255, 255, 1);
  static const Color kvk_grey = Color.fromRGBO(196, 196, 196, 1);
  static const Color kvk_nav_grey = Color.fromRGBO(218, 220, 218, 1);
  static const Color kvk_nav_dark_grey = Color.fromRGBO(59, 59, 59, 1);
  static const Color kvk_black = Color.fromRGBO(0, 0, 0, 1);
  static const Color kvk_orange = Color.fromRGBO(240, 106, 0, 1);
  static const Color kvk_eclipse_1 = Color.fromRGBO(105, 219, 81, 0.5);
  static const Color kvk_eclipse_2 = Color.fromRGBO(105, 219, 81, 0.8);
  static const Color kvk_success_green = Color.fromRGBO(105, 219, 81, 1);
  static const Color kvk_error_red = Color.fromRGBO(223, 27, 63, 1);
  static const Color kvk_dark_grey = Color.fromRGBO(89, 89, 89, 1);
  static const Color kvk_background_grey = Color.fromRGBO(238, 240, 242, 1);
  static const Color kvk_post_grey = Color.fromRGBO(122, 122, 122, 1);
  static const Color kvk_topic_highlight = Color.fromRGBO(221, 255, 226, 0.6);
  static const Color kvk_title_green = Color.fromRGBO(0, 120, 0, 1);
  static const Color kvk_leaf_green = Color.fromRGBO(127, 176, 105, 1);
}
