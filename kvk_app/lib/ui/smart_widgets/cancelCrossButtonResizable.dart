import 'package:flutter/material.dart';
import 'package:kvk_app/icons/kvk_icons.dart';

class RCrossButton extends StatelessWidget {
  const RCrossButton({this.color, this.onPressed, this.size});

  final Color color;
  final VoidCallback onPressed;
  final double size;

  /// Creates the button found at the top of many of the pages, allowing the user to go back
  /// param: BuildContext [context]
  /// returns: IconButton
  /// Initial creation: 17/09/2020
  /// Last Updated: 17/09/2020
  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    return IconButton(
      iconSize: size != null ? size : 24.0,
      icon: Icon(
        KVKIcons.multiply_figma_exported_custom,
        size: 24,
      ),
      color: color,
      onPressed: () {
        if (onPressed != null) {
          onPressed();
        } else {
          Navigator.maybePop(context);
        }
      },
    );
  }
}
