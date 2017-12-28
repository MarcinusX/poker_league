import 'package:flutter/material.dart';

class NumericSlider extends StatefulWidget {
  final int minValue;
  final int maxValue;
  final ValueChanged<int> valueChanged;

  NumericSlider({this.valueChanged, this.minValue, this.maxValue});

  @override
  State<StatefulWidget> createState() {
    return new NumericSliderState();
  }
}

class NumericSliderState extends State<NumericSlider> {
  TextEditingController _textController;
  double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.minValue.toDouble();
    _textController =
        new TextEditingController(text: _value.toInt().toString());
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    widget.valueChanged(_value.toInt());
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        new Expanded(
          flex: 7,
          child: new Slider(
            min: widget.minValue.toDouble(),
            max: widget.maxValue.toDouble(),
            divisions: widget.maxValue - widget.minValue + 1,
            value: _value,
            onChanged: (newValue) => setState(() {
                  _value = newValue;
                  _textController = new TextEditingController(
                      text: _value.toInt().toString());
                }),
          ),
        ),
        new Expanded(
          flex: 1,
          child: new TextField(
            keyboardType: TextInputType.number,
            controller: _textController,
            onChanged: (string) => setState(() {
                  double newValue = double.parse(string);
                  print("String $string newValue $newValue");
                  if (newValue < widget.minValue || newValue == null) {
                    newValue = widget.minValue.toDouble();
                    _textController = new TextEditingController(
                        text: newValue.toInt().toString());
                  } else if (newValue > widget.maxValue) {
                    newValue = widget.maxValue.toDouble();
                    _textController = new TextEditingController(
                        text: newValue.toInt().toString());
                  }
                  _value = newValue;
                }),
            maxLength: 4,
          ),
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }
}
