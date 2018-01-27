import 'dart:math' as math;

import 'package:flutter/material.dart';

class NumericSlider extends StatelessWidget {
  final int minValue;
  final int maxValue;
  final int value;
  final ValueChanged<int> valueChanged;

  NumericSlider({this.minValue, this.maxValue, this.value, this.valueChanged});

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        new Expanded(
          flex: 3,
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
            child: new Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                new Text(value.toString()),
                new IconButton(
                    icon: new Icon(Icons.edit),
                    onPressed: () {
                      TextEditingController _controller =
                      new TextEditingController(text: value.toString());
                      showDialog(
                          context: context,
                          child: new AlertDialog(
                            content: new TextField(
                              controller: _controller,
                              decoration: new InputDecoration(
                                labelText: "Checkout value",
                                counterText: "",
                              ),
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                            ),
                            actions: [
                              new FlatButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: new Text("CANCEL"),
                              ),
                              new FlatButton(
                                onPressed: () =>
                                    Navigator
                                        .of(context)
                                        .pop(int.parse(_controller.text)),
                                child: new Text("OK"),
                              ),
                            ],
                          )).then((int newValue) {
                        if (newValue != null) {
                          newValue = math.min(maxValue, newValue);
                          newValue = math.max(minValue, newValue);
                          valueChanged(newValue);
                        }
                      });
                    })
              ],
            )),
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }
}