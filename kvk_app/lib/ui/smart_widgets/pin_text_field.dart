import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kvk_app/app/logger.dart';
import 'package:kvk_app/ui/coloursheet.dart';
import 'package:kvk_app/ui/smart_widgets/text_colorizer.dart';

final log = getLogger('Pin-Text-Field');

class PinTextField extends StatefulWidget {
  final String lastPin;
  final int fields;
  final onSubmit;
  final fieldWidth;
  final fontSize;
  final isTextObscure;
  final showFieldAsBox;
  final textColor;
  final onChange;

  PinTextField(
      {this.lastPin,
      this.fields: 4,
      this.textColor: Colour.kvk_black,
      this.onSubmit,
      this.fieldWidth: 40.0,
      this.fontSize: 20.0,
      this.isTextObscure: false,
      this.showFieldAsBox: false,
      this.onChange})
      : assert(fields > 0);

  @override
  State createState() {
    return PinTextFieldState();
  }
}

  /// This creates the verification pin page, and allows for moving back and forth
  /// between the different text fields.
  ///
  /// Initial creation: 12/09/2020
  /// Last Updated: 12/09/2020
class PinTextFieldState extends State<PinTextField> {
  List<String> _pin;
  List<FocusNode> _focusNodes;
  List<TextColorizer> _textControllers;

  Widget textfields = Container();

  @override
  void initState() {
    super.initState();
    _pin = List<String>(widget.fields);
    _focusNodes = List<FocusNode>(widget.fields);
    _textControllers = List<TextColorizer>(widget.fields);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        if (widget.lastPin != null) {
          for (var i = 0; i < widget.lastPin.length; i++) {
            _pin[i] = widget.lastPin[i];
          }
        }
        textfields = generateTextFields(context);
      });
    });
  }

  @override
  void dispose() {
    _textControllers.forEach((TextColorizer t) => t.dispose());
    super.dispose();
  }

  Widget generateTextFields(BuildContext context) {
    List<Widget> textFields = List.generate(widget.fields, (int i) {
      return buildTextField(i, context);
    });

    if (_pin.first != null) {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    }

    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        verticalDirection: VerticalDirection.down,
        children: textFields);
  }

  void clearTextFields() {
    _textControllers.forEach(
        (TextEditingController tEditController) => tEditController.clear());
    _pin.clear();
  }

  /// Create the varying text fields and provide them with focusnodes. 
  /// Set all "." to be transparent color (This is what allows for navigating back through the textfields)
  /// param: BuildContext [context]
  /// returns: Container
  /// Initial creation: 5/09/2020
  /// Last Updated: 5/09/2020
  Widget buildTextField(int i, BuildContext context) {
    if (_focusNodes[i] == null) {
      _focusNodes[i] = FocusNode();
    }
    if (_textControllers[i] == null) {
      _textControllers[i] =
          TextColorizer({'.': TextStyle(color: Colors.transparent)});
      if (widget.lastPin != null) {
        _textControllers[i].text = widget.lastPin[i];
      }
    }

    _focusNodes[i].addListener(() {
      if (_focusNodes[i].hasFocus) {
        for (var j = 0; j < i; j++) {
          if (_textControllers[j].text == ".") {
            _focusNodes[j].requestFocus();
          }
        }
        for (var x = 0; x <= i; x++) {
          if (x + 1 != widget.fields) {
            if (_textControllers[x].text != ".") {
              _focusNodes[x + 1].requestFocus();
            }
          }
        }
      }
    });

  //Set all textfields to have a starting value of "."
    _textControllers[i].text = '.';
    bool isLastDigitUsed = false;

    return Container(
      width: widget.fieldWidth,
      margin: EdgeInsets.only(right: 10.0),
      child: TextField(
        inputFormatters: [
          new WhitelistingTextInputFormatter(RegExp("[0-9]")),
        ],
        cursorColor: widget.textColor,
        controller: _textControllers[i],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: widget.textColor,
            fontSize: widget.fontSize),
        focusNode: _focusNodes[i],
        obscureText: widget.isTextObscure,
        decoration: InputDecoration(
          counterText: "",
          border: widget.showFieldAsBox
              ? OutlineInputBorder(borderSide: BorderSide(width: 2.0))
              : null,
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
            color: Colour.kvk_white,
            width: 2.0,
          )),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
            color: Colour.kvk_white,
            width: 4.0,
          )),
        ),
        onTap: () {
          _textControllers[i].selection = TextSelection.fromPosition(
              TextPosition(offset: _textControllers[i].text.length));
        },
        onChanged: (String str) {
          _pin[i] = _textControllers[i]
              .text
              .substring(_textControllers[i].text.indexOf(".") + 1);
          log.d(_pin);

          if (_pin.every((String digit) => digit != null && digit != '.')) {
            widget.onChange(_pin.join());
          }

          if (i == widget.fields - 1 && isNumeric(_textControllers[i].text)) {
            isLastDigitUsed = true;
          }

          log.d(_textControllers[i].text );

          if (_textControllers[i].text == '' &&
              _textControllers[i] == _textControllers[0]) {
            _textControllers[i].text = ".";
          }
          if (_textControllers[i].text == '') {
            if ((i == widget.fields - 1)&&isLastDigitUsed) {
              _textControllers[i].text = ".";
              FocusScope.of(context).requestFocus(_focusNodes[i-1]);
              isLastDigitUsed = false;
            } else {
              FocusScope.of(context).requestFocus(_focusNodes[i - 1]);
              _textControllers[i].text = ".";
              _textControllers[i - 1].text = ".";
            }
          } else {
            FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
          }
        },
        onSubmitted: (String str) {
          log.d("onSubmit");
          if (_pin.every((String digit) => digit != null && digit != '.')) {
            widget.onSubmit(_pin.join());
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return textfields;
  }

  /// Ensures all text is numeric entered into the textfield
  /// param: String [s]
  /// returns: boolean
  /// Initial creation: 5/09/2020
  /// Last Updated: 5/09/2020
  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }
}


