import 'package:flutter/material.dart';

  /// Colors certain text in a textfield as provided
  /// param: Mapping
  /// returns: TextSpan with style
  /// Initial creation: 16/09/2020
  /// Last Updated: 16/09/2020
class TextColorizer extends TextEditingController {
  final Map<String, TextStyle> mapping;
  final Pattern pattern;

  TextColorizer(this.mapping)
      : pattern =
            RegExp(mapping.keys.map((key) => RegExp.escape(key)).join('|'));
  @override
  TextSpan buildTextSpan({TextStyle style, bool withComposing}) {
    List<InlineSpan> children = [];
    // splitMapJoin is a bit tricky here but i found it very handy for populating children list
    text.splitMapJoin(
      pattern,
      onMatch: (Match match) {
        children.add(
            TextSpan(text: match[0], style: style.merge(mapping[match[0]])));
      },
      onNonMatch: (String text) {
        children.add(TextSpan(text: text, style: style));
      },
    );
    return TextSpan(style: style, children: children);
  }
}