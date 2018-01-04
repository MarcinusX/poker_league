import 'package:flutter/material.dart';

class NumericSlider extends StatelessWidget {
  final int minValue;
  final int maxValue;
  final int value;
  final ValueChanged<int> valueChanged;
  TextEditingController _textController;

  NumericSlider({this.minValue, this.maxValue, this.value, this.valueChanged}) {
    _textController = new TextEditingController(text: value.toInt().toString());
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        new Expanded(
          flex: 7,
          child: new Slider(
            min: minValue.toDouble(),
            max: maxValue.toDouble(),
            divisions: maxValue - minValue + 1,
            value: value.toDouble(),
            onChanged: (dub) => valueChanged(dub.toInt()),
          ),
        ),
        new Expanded(
          flex: 1,
          child: new TextField(
            keyboardType: TextInputType.number,
            controller: _textController,
            onChanged: (string) {
//              double newValue = double.parse(string);
//              print("String $string newValue $newValue");
//              if (newValue < widget.minValue || newValue == null) {
//                newValue = widget.minValue.toDouble();
//                _textController = new TextEditingController(
//                    text: newValue.toInt().toString());
//              } else if (newValue > widget.maxValue) {
//                newValue = widget.maxValue.toDouble();
//                _textController = new TextEditingController(
//                    text: newValue.toInt().toString());
//              }
//              _value = newValue;
            },
            maxLength: 4,
          ),
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }
}

//_textController = new TextEditingController(
//text: _value.toInt().toString());
