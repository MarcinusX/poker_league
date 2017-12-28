import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:poker_league/models/player.dart';
import 'package:poker_league/models/session.dart';
import 'package:poker_league/widgets/sessions/session/checkout_dialog.dart';

class ViewModel {
  final Session session;
  final Function(Player, BuyIn) doBuyIn;
  final Function(Player, Checkout) doCheckout;

  ViewModel({this.session, this.doBuyIn, this.doCheckout});
}

class SessionPage extends StatelessWidget {
  static const double _appBarHeight = 256.0;

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, ViewModel>(
      converter: (store) {
        return new ViewModel(
          session: store.state.activeSession,
          doBuyIn: (player, buyIn) =>
              store.dispatch(new DoBuyIn(player, buyIn)),
          doCheckout: (player, checkout) =>
              store.dispatch(new DoCheckout(player, checkout)),
        );
      },
      builder: (context, viewModel) {
        return new Scaffold(
          body: new CustomScrollView(
            slivers: [
              new SliverAppBar(
                expandedHeight: _appBarHeight,
                pinned: true,
                flexibleSpace: new FlexibleSpaceBar(
                  title:
                      new Text("Total: " + viewModel.session.total.toString()),
                  centerTitle: true,
                  background: new DefaultTextStyle(
                    style: Theme
                        .of(context)
                        .textTheme
                        .headline
                        .copyWith(color: Colors.white),
                    child: new Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        new Image.asset(
                          'assets/poker_case.jpg',
                          fit: BoxFit.cover,
                          height: _appBarHeight,
                        ),
                        const DecoratedBox(
                          decoration: const BoxDecoration(
                            gradient: const LinearGradient(
                              begin: const FractionalOffset(0.5, 1.0),
                              end: const FractionalOffset(0.5, 0.7),
                              colors: const <Color>[
                                Colors.black,
                                const Color(0x00000000)
                              ],
                            ),
                          ),
                        ),
                        new Center(
                          child: new Padding(
                            padding: new EdgeInsets.only(top: 64.0),
                            child: new Column(
                              children: <Widget>[
                                new Text("Cash: " +
                                    viewModel.session.cash.toString()),
                                new Text("Debt: " +
                                    viewModel.session.debt.toString()),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              new SliverList(
                delegate: new SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  PlayerSession playerSession =
                      viewModel.session.playerSessions.values.toList()[index];
                  bool hasCheckedOut = playerSession.checkout != null;
                  return new ExpansionTile(
                    title: new Text(
                      playerSession.player.name,
                      style: Theme.of(context).textTheme.headline.copyWith(
                          color: hasCheckedOut ? Colors.grey : Colors.black),
                    ),
                    trailing: new Text(playerSession.balance.toString()),
                    children: <Widget>[
                      new ListTile(
                        title: new Text(
                            "Cash: " + playerSession.cashBuyIn.toString()),
                        trailing: new FlatButton(
                          onPressed: (hasCheckedOut
                              ? null
                              : (() {
                                  _openBuyInDialog(context, true).then((value) {
                                    if (value != null) {
                                      viewModel.doBuyIn(playerSession.player,
                                          new BuyIn(value));
                                    }
                                  });
                                })),
                          child: new Text("ADD CASH"),
                        ),
                      ),
                      new ListTile(
                        title: new Text(
                            "Debt: " + playerSession.debtBuyIn.toString()),
                        trailing: new FlatButton(
                          onPressed: (hasCheckedOut
                              ? null
                              : (() {
                                  _openBuyInDialog(context, false)
                                      .then((value) {
                                    if (value != null) {
                                      viewModel.doBuyIn(playerSession.player,
                                          new BuyIn(value, isCash: false));
                                    }
                                  });
                                })),
                          child: new Text("ADD DEBT"),
                        ),
                      ),
                      new ListTile(
                        title: new Text("Checkout: " +
                            playerSession.checkoutTotal.toString()),
                        trailing: new FlatButton(
                          onPressed: (hasCheckedOut
                              ? null
                              : (() {
                                  showDialog<Checkout>(
                                    context: context,
                                    child: new CheckoutDialog(
                                      playerSession.player,
                                      viewModel.session,
                                    ),
                                  ).then((Checkout checkout) {
                                    if (checkout != null) {
                                      viewModel.doCheckout(
                                          playerSession.player, checkout);
                                    }
                                  });
                                })),
                          child: new Text("CHECKOUT"),
                        ),
                      ),
                    ],
                  );
                }, childCount: viewModel.session.playerSessions.length),
              ),
            ],
          ),
        );
      },
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
