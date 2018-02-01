import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';
import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/checkout_actions.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:poker_league/models/player.dart';
import 'package:poker_league/models/session.dart';
import 'package:poker_league/widgets/sessions/session/edit_session_page.dart';
import 'package:poker_league/widgets/sessions/session/timeline.dart';
import 'package:tuple/tuple.dart';

class ViewModel {
  final Session session;
  final Function(Player, BuyIn) doBuyIn;
  final Function(Player, Checkout) doCheckout;
  final Function(Player) prepareCheckoutPage;
  final Function(Player, bool) setExpanded;
  final Map<Player, bool> arePlayersExpanded;

  ViewModel({
    this.session,
    this.doBuyIn,
    this.doCheckout,
    this.prepareCheckoutPage,
    this.arePlayersExpanded,
    this.setExpanded,
  });
}

class SessionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      new StoreConnector<ReduxState, ViewModel>(
        converter: (store) {
          return new ViewModel(
              session: store.state.activeSession,
              doBuyIn: (player, buyIn) =>
                  store.dispatch(new DoBuyIn(player, buyIn)),
              doCheckout: (player, checkout) =>
                  store.dispatch(new DoCheckout(player, checkout)),
              prepareCheckoutPage: (player) =>
                  store.dispatch(
                      new InitCheckout(player, store.state.activeSession)),
              arePlayersExpanded: store.state.sessionPageState.playersExpanded,
              setExpanded: (player, isExpanded) =>
                  store
                      .dispatch(
                      new SessionSetExpandedAction(player, isExpanded)));
        },
        builder: (context, viewModel) {
          return new Scaffold(
            appBar: new AppBar(
              title: new Text("Session details"),
              actions: [
                new IconButton(
                  icon: new Icon(Icons.settings),
                  onPressed: () {
                    Navigator.of(context).push(new MaterialPageRoute(
                      builder: (BuildContext context) =>
                      new EditSessionPage(),
                    ));
                  },
                )
              ],
            ),
            body: new ListView(
              children: [
                new Padding(
                  padding: new EdgeInsets.all(12.0),
                  child: new Card(
                    child: new Padding(
                      padding: new EdgeInsets.all(16.0),
                      child: new Column(
                          children: [
                            new Row(children: [
                              new Expanded(child: new Text("Cash buy ins")),
                              new Text(viewModel.session.cash.toString()),
                            ]),
                            new Divider(height: 4.0,),
                            new Row(children: [
                              new Expanded(child: new Text("Debt buy ins")),
                              new Text(viewModel.session.debt.toString()),
                            ]),
                            new Divider(height: 4.0,),
                            new Row(children: [
                              new Expanded(child: new Text("Total buy ins")),
                              new Text(viewModel.session.cash.toString()),
                            ]),
                            new Divider(height: 4.0,),
                            new Row(children: [
                              new Expanded(child: new Text("Checkouts")),
                              new Text(viewModel.session.debt.toString()),
                            ]),
                            new Divider(height: 4.0,),
                            new Row(children: [
                              new Expanded(child: new Text("Total on board")),
                              new Text(viewModel.session.debt.toString()),
                            ]),
                            new Divider(height: 4.0,),
                          ]
                      ),
                    ),
                  ),
                ),

                new Padding(
                  padding: new EdgeInsets.all(16.0),
                  child: new ExpansionPanelList(
                    expansionCallback: (int index, bool isExpanded) {
                      viewModel.setExpanded(
                          viewModel.session.playerSessions.keys.toList()[index],
                          !isExpanded);
                    },
                    children: viewModel.session.playerSessions.keys
                        .map((Player player) =>
                        _createExpansionPanel(context, viewModel, player))
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        },
      );

  ExpansionPanel _createExpansionPanel(BuildContext context,
      ViewModel viewModel, Player player) {
    return new ExpansionPanel(
      headerBuilder: (BuildContext context, bool isExpanded) {
        int balance = viewModel.session.playerSessions[player].balance;
        return new ListTile(
          title: new Text(player.name),
          subtitle: new Text("Balance: $balance"),
        );
      },
      isExpanded: viewModel.arePlayersExpanded[player],
      body: new Column(
        children: <Widget>[
          new Padding(
            padding: new EdgeInsets.symmetric(horizontal: 16.0),
            child: new TimeLine(
              items:
              viewModel.session.playerSessions[player].buyIns.map((buyIn) {
                return new Tuple2(buyIn.dateTime, {
                  "buyIn": buyIn,
                  "playerSession": viewModel.session.playerSessions[player]
                });
              }).toList(),
              dateWidgetGenerator: (DateTime dateTime) {
                return new Text(
                  new DateFormat(DateFormat.HOUR24_MINUTE).format(dateTime),
                  style: Theme
                      .of(context)
                      .textTheme
                      .caption,
                );
              },
              contentWidgetGenerator: (data) {
                BuyIn buyIn = data["buyIn"];
                Iterable<BuyIn> buyInsAtTime = (data["playerSession"]
                as PlayerSession)
                    .buyIns
                    .where((item) => !item.dateTime.isAfter(buyIn.dateTime));
                int balanceAtTime =
                buyInsAtTime.fold(0, (int, buyIn) => int + buyIn.value);
                int debtBalanceAtTime = buyInsAtTime.fold(
                    0, (int, buyIn) => int + (buyIn.isCash ? 0 : buyIn.value));
                int buyInValue = buyIn.value;
                String buyInType = buyIn.isCash ? "cash" : "debt";
                return new Row(
                  children: <Widget>[
                    new Expanded(
                      child: new RichText(
                        text: new TextSpan(
                            text: "Buy in for ",
                            style: Theme
                                .of(context)
                                .textTheme
                                .subhead,
                            children: [
                              new TextSpan(
                                text: "$buyInValue",
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .subhead
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              new TextSpan(
                                text: " in $buyInType",
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .subhead,
                              ),
                            ]),
                      ),
                    ),
                    new Text(
                      (debtBalanceAtTime == 0
                          ? "$balanceAtTime"
                          : "($debtBalanceAtTime) $balanceAtTime"),
                      style: Theme
                          .of(context)
                          .textTheme
                          .subhead,
                    )
                  ],
                );
              },
            ),
          ),
          new Divider(
            height: 2.0,
          ),
          new ButtonBar(
            children: <Widget>[
              new FlatButton(
                onPressed: null,
                child: new Text("CHECKOUT"),
              ),
              new FlatButton(
                onPressed: () {
                  _openBuyInDialog(context, true).then((value) {
                    if (value != null) {
                      viewModel.doBuyIn(player,
                          new BuyIn(value, new DateTime.now(), isCash: false));
                    }
                  });
                },
                child: new Text("BUY IN"),
              )
            ],
          )
        ],
      ),
    );
  }
}

class DiscreteSlider extends StatefulWidget {
  final ValueChanged<int> valueChanged;

  DiscreteSlider(this.valueChanged);

  @override
  State<StatefulWidget> createState() {
    return new DiscreteSliderState();
  }
}

class DiscreteSliderState extends State<DiscreteSlider> {
  double _value = 20.0;

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: [
        new Row(
          children: [
            new Expanded(
              child: new Slider(
                value: _value,
                onChanged: (value) => setState(() {
                      widget.valueChanged(value.toInt());
                      _value = value;
                    }),
                min: 10.0,
                max: 100.0,
                divisions: 18,
                label: _value.round().toString(),
              ),
            ),
            new Text(_value.round().toString()),
          ],
        ),
      ],
      mainAxisSize: MainAxisSize.min,
    );
  }
}

Future<int> _openBuyInDialog(BuildContext context, bool isCash) {
  String title = isCash ? "Cash buy in" : "Debt buy in";
  int saved = 20;
  return showDialog(
    context: context,
    barrierDismissible: false,
    child: new AlertDialog(
      title: new Text(title),
      content: new DiscreteSlider((value) => saved = value),
      actions: [
        new FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: new Text("CANCEL")),
        new FlatButton(
            onPressed: () => Navigator.of(context).pop(saved),
            child: new Text("BUY IN"))
      ],
    ),
  );
}
