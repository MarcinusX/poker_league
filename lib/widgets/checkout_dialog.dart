import 'package:flutter/material.dart';
import 'package:poker_league/models/player.dart';
import 'package:poker_league/models/session.dart';

class CheckoutDialog extends StatefulWidget {
  final Player player;
  final Session session;
  final Map<Player, int> playerDebts;

  CheckoutDialog(this.player, this.session)
      : playerDebts = new Map<Player, int>.fromIterable(
          session.playerSessions.values.where((ps) => ps.debtBuyIn != 0),
          key: (PlayerSession ps) => ps.player,
          value: (PlayerSession ps) => ps.debtBuyIn,
        );

  @override
  State<StatefulWidget> createState() {
    return new CheckoutDialogState();
  }
}

class CheckoutDialogState extends State<CheckoutDialog> {
  Map<Player, int> _checkoutsFromDebts;
  int _cashCheckout = 0;
  int _totalCheckout = 0;

  int get leftResources =>
      _totalCheckout -
      _cashCheckout -
      (_checkoutsFromDebts.isEmpty
          ? 0
          : _checkoutsFromDebts.values.reduce((a, b) => a + b));

  @override
  void initState() {
    super.initState();
    _checkoutsFromDebts = new Map.fromIterable(
      widget.playerDebts.keys,
      key: (player) => player,
      value: (player) => 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Checkout: " + widget.player.name),
        actions: [
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(
                  new Checkout(
                      cashValue: _cashCheckout,
                      debtValues: _checkoutsFromDebts),
                ),
            child: new Text("CONFIRM",
                style: Theme
                    .of(context)
                    .textTheme
                    .subhead
                    .copyWith(color: Colors.white)),
          )
        ],
      ),
      body: new SingleChildScrollView(
        child: new Padding(
          padding: new EdgeInsets.symmetric(horizontal: 16.0),
          child: new Column(
            children: <Widget>[
              new TextField(
                decoration: new InputDecoration(labelText: "Total outcome"),
                keyboardType: TextInputType.number,
                onChanged: (value) =>
                    setState(() => _totalCheckout = int.parse(value)),
              ),
              (_totalCheckout == 0
                  ? new Container()
                  : new TextField(
                      decoration: new InputDecoration(labelText: "Cash"),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => setState(() =>
                          _cashCheckout = value.isEmpty ? 0 : int.parse(value)),
                    )),
              new ListView.builder(
                  shrinkWrap: true,
                  itemExtent: 80.0,
                  itemCount:
                      (_totalCheckout == 0 ? 0 : widget.playerDebts.length),
                  itemBuilder: (BuildContext context, int index) {
                    Player player = widget.playerDebts.keys.toList()[index];
                    return new TextField(
                      decoration: new InputDecoration(
                          labelText: "Debt from " + player.name),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => setState(() =>
                          _checkoutsFromDebts[player] =
                              value.isEmpty ? 0 : int.parse(value)),
                    );
                  }),
            ],
            mainAxisSize: MainAxisSize.min,
          ),
        ),
      ),
    );
  }
}

//new ListTile(
//title: new Text("Total: $_totalCheckout"),
//onTap: () {
//showDialog<int>(
//context: context,
//child: new NumberPickerDialog.integer(
//minValue: 0,
//maxValue: widget.session.total,
//initialIntegerValue: _totalCheckout))
//    .then((value) => setState(() => _totalCheckout = value));
//},
//),
