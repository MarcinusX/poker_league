import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:poker_league/models/player.dart';
import 'package:poker_league/models/session.dart';
import 'package:poker_league/widgets/sessions/session/numeric_slider.dart';

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

  int get _moneyDeclaredToCheckout =>
      _cashCheckout +
          (_checkoutsFromDebts.isEmpty
              ? 0
              : _checkoutsFromDebts.values.reduce((a, b) => a + b));

  int get _leftResources => _totalCheckout - _moneyDeclaredToCheckout;

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
            onPressed: (_leftResources == 0
                ? () =>
                Navigator.of(context).pop(
                  new Checkout(
                      cashValue: _cashCheckout,
                      debtValues: _checkoutsFromDebts),
                )
                : null),
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
              new Text("Total checkout"),
              new NumericSlider(
                valueChanged: (newValue) =>
                    setState(() => _totalCheckout = newValue),
                minValue: _moneyDeclaredToCheckout,
                maxValue: widget.session.total,
              ),
              new Divider(),
              (_totalCheckout == 0
                  ? new Container()
                  : new Column(
                children: [
                  new Text("Cash"),
                  new NumericSlider(
                    valueChanged: (newValue) =>
                        setState(() => _cashCheckout = newValue),
                    minValue: 0,
                    maxValue: _leftResources,
                  ),
                ],
              )),
              new ListView.builder(
                  shrinkWrap: true,
                  itemExtent: 80.0,
                  itemCount:
                  (_totalCheckout == 0 ? 0 : widget.playerDebts.length),
                  itemBuilder: (BuildContext context, int index) {
                    Player player = widget.playerDebts.keys.toList()[index];
                    int debt = widget.playerDebts[player];

                    return new Column(
                      children: [
                        new Text("Debt from " + player.name),
                        new NumericSlider(
                          valueChanged: (newValue) =>
                              setState(
                                      () =>
                                  _checkoutsFromDebts[player] = newValue),
                          minValue: player == widget.player
                              ? math.min(_leftResources, debt)
                              : 0,
                          maxValue: math.min(_leftResources, debt),
                        ),
                      ],
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
