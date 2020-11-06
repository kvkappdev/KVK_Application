import 'package:flutter/material.dart';

class RBackButton extends BackButton {
  const RBackButton({Key key, this.color, this.onPressed, this.size})
      : super(key: key);

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
      icon: const BackButtonIcon(),
      color: color,
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
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
