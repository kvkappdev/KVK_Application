import 'package:flutter/material.dart';
import 'package:kvk_app/ui/coloursheet.dart';

class TabItem extends StatelessWidget {
  final String message;
  final IconData icon;
  final bool isSelected;
  final Function onTap;
  final Color iconColor;

  const TabItem(
      {@required this.message,
      @required this.icon,
      this.onTap,
      this.iconColor = Colour.kvk_dark_grey,
      this.isSelected});

  /// Create each item for the BottomNavBar
  ///
  /// param: BuildContext [context]
  /// returns: InkWell
  /// Initial creation: 22/09/2020
  /// Last Updated: 04/10/2020
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon,
                color: isSelected ? Colour.kvk_orange : iconColor),
            Text(
              message,
              style: TextStyle(
                  color: isSelected ? Colour.kvk_orange : Colour.kvk_dark_grey),
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
