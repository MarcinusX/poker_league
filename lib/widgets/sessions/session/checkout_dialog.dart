import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class CheckoutDialog extends StatefulWidget {
  final int maxValue;
  final int initialValue;

  CheckoutDialog({@required this.maxValue, this.initialValue});

  @override
  State<StatefulWidget> createState() {
    return new CheckoutDialogState(value: initialValue);
  }
}

class CheckoutDialogState extends State<CheckoutDialog> {
  int value;
  TextEditingController _controller;

  CheckoutDialogState({this.value = 0});

  @override
  void initState() {
    super.initState();
    _controller = new TextEditingController(text: value.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: new Text("Checkout"),
      content: new Column(
        children: <Widget>[
          new Row(
            children: [
              new Expanded(
                flex: 5,
                child: new Slider(
                  value: value.toDouble(),
                  onChanged: (int) => setState(() {
                        value = int.round();
                        _controller.text = value.toString();
                      }),
                  min: 0.0,
                  max: widget.maxValue.toDouble(),
                  divisions: widget.maxValue,
                  label: value.round().toString(),
                ),
              ),
              new Expanded(
                flex: 1,
                child: new TextField(
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  controller: _controller,
                  onChanged: (string) => setState(() {
                        int newValue = int.parse(string);
                        if (newValue == null) {
                          newValue = 0;
                          _controller.text = newValue.toString();
                        } else if (newValue > widget.maxValue) {
                          newValue = widget.maxValue;
                          _controller.text = newValue.toString();
                        }
                        value = newValue;
                      }),
                ),
              )
            ],
          ),
        ],
        mainAxisSize: MainAxisSize.min,
      ),
      actions: [
        new FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: new Text("CANCEL")),
        new FlatButton(
            onPressed: () => Navigator.of(context).pop(value),
            child: new Text("CHECKOUT"))
      ],
    );
  }
}
