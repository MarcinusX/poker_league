import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:poker_league/models/session.dart';

class BuyInDialog extends StatefulWidget {
  final BuyIn buyInToEdit;

  BuyInDialog() : buyInToEdit = null;

  BuyInDialog.edit(this.buyInToEdit);

  @override
  State<StatefulWidget> createState() {
    return new BuyInDialogState();
  }
}

class BuyInDialogState extends State<BuyInDialog> {
  bool _isCash = true;
  int _value = 20;

  @override
  void initState() {
    super.initState();
    _isCash = widget.buyInToEdit?.isCash ?? true;
    _value = widget.buyInToEdit?.value ?? 20;
  }

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: new Text("Buy in"),
      content: new Column(
        children: <Widget>[
          new Row(
            children: <Widget>[
              new Expanded(child: new Text("Cash")),
              new Switch(
                  value: _isCash,
                  onChanged: (checked) => setState(() => _isCash = checked)),
            ],
          ),
          new Row(
            children: [
              new Text("Value: " + _value.round().toString()),
              new Expanded(
                child: new Slider(
                  value: _value.toDouble(),
                  onChanged: (value) => setState(() => _value = value.round()),
                  min: 10.0,
                  max: 100.0,
                  divisions: 18,
//                  label: _value.round().toString(),
                ),
              ),
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
            onPressed: () {
              DateTime dateTime =
                  widget.buyInToEdit?.dateTime ?? new DateTime.now();
              String key = widget.buyInToEdit?.key;
              Navigator
                  .of(context)
                  .pop(new BuyIn(_value, dateTime, isCash: _isCash, key: key));
            },
            child: new Text("BUY IN"))
      ],
    );
  }
}
